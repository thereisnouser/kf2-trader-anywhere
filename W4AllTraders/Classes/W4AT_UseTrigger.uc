// Невидимый личный торговец: штатная подсказка и удержание E для автозакупки.
class W4AT_UseTrigger extends KFTraderTrigger;

var KFPlayerController OwnerController;
var repnotify Pawn TrackedPawn;
var bool bLastTraderPhase;

replication
{
    if (Role == ROLE_Authority && bNetDirty)
        TrackedPawn;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.10, true, nameof(FollowPawn));
}

function InitFor(KFPlayerController KFPC)
{
    OwnerController = KFPC;
    TrackedPawn = KFPC.Pawn;
    bForceNetUpdate = true;

    SetCollision(true, false);
    SetLocation(TrackedPawn.Location);
    bLastTraderPhase = IsTraderPhase();

    // Нужна первая подсказка сразу после создания триггера.
    class'KFPlayerController'.static.UpdateInteractionMessages(TrackedPawn);
}

simulated function bool IsTraderPhase()
{
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    return KFGRI != None && KFGRI.bTradersEnabled && KFGRI.bTraderIsOpen;
}

simulated function FollowPawn()
{
    local bool bTrading;

    if (TrackedPawn == None)
    {
        return;
    }

    if (Role == ROLE_Authority
        && (OwnerController == None || TrackedPawn.bDeleteMe
            || OwnerController.Pawn != TrackedPawn || !TrackedPawn.IsAliveAndWell()))
    {
        Destroy();
        return;
    }

    // На клиенте триггер также должен находиться около своего игрока:
    // KFPlayerInput ищет торговца локально для удержания E.
    SetLocation(TrackedPawn.Location);

    if (Role == ROLE_Authority)
    {
        bTrading = IsTraderPhase();
        if (bTrading != bLastTraderPhase)
        {
            bLastTraderPhase = bTrading;
            class'KFPlayerController'.static.UpdateInteractionMessages(TrackedPawn);
        }
    }
}

simulated function bool GetIsUsable(Pawn User)
{
    if (User == None || TrackedPawn == None || User != TrackedPawn
        || !User.IsAliveAndWell())
    {
        return false;
    }

    if (Role == ROLE_Authority && User.Controller != OwnerController)
    {
        return false;
    }

    return IsTraderPhase();
}

function int GetInteractionIndex(Pawn User)
{
    local Actor A;
    local KFInterface_Usable Usable;

    // Если рядом есть обычный доступный объект, не перехватываем E.
    foreach User.TouchingActors(class'Actor', A)
    {
        if (A == Self)
        {
            continue;
        }

        Usable = KFInterface_Usable(A);
        if (Usable != None && Usable.GetIsUsable(User))
        {
            return IMT_None;
        }
    }

    // Нативный текст, иконка E и подсказка удержания для автозакупки.
    return IMT_UseTrader;
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp,
    vector HitLocation, vector HitNormal)
{
    // Не вызываем KFTraderTrigger.Touch: он проигрывает реплики при подходе.
    if (Role == ROLE_Authority && Other == TrackedPawn)
    {
        class'KFPlayerController'.static.UpdateInteractionMessages(Other);
    }
}

simulated event UnTouch(Actor Other)
{
    if (Role == ROLE_Authority && Other == TrackedPawn)
    {
        class'KFPlayerController'.static.UpdateInteractionMessages(Other);
    }
}

function bool UsedBy(Pawn User)
{
    if (!GetIsUsable(User))
    {
        return false;
    }

    OwnerController.OpenTraderMenu();
    return true;
}

defaultproperties
{
    Begin Object Name=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
        CollisionRadius=+00256.000000
        CollisionHeight=+00256.000000
        BlockZeroExtent=false
    End Object

    bCollideActors=true
    bBlockActors=false
    bProjTarget=false
    bHidden=true
    bNoDelete=false
    bOpened=true
    bEnabled=true
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
    RemoteRole=ROLE_SimulatedProxy
}
