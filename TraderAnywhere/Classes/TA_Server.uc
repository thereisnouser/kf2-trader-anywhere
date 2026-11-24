// Серверная логика открывания всех кабин и удалённого взаимодействия.
// Отдельный Info нужен для совместимости с Safe Mut Loader.
class TA_Server extends Info;

var TA_State TraderState;

public event PostBeginPlay()
{
    local TA_Server OtherServer;

    Super.PostBeginPlay();

    if (WorldInfo.NetMode == NM_Client)
    {
        return;
    }

    // Не запускаем два независимых таймера, если объект создан повторно.
    foreach WorldInfo.DynamicActors(class'TA_Server', OtherServer)
    {
        if (OtherServer != Self && !OtherServer.bDeleteMe)
        {
            Destroy();
            return;
        }
    }

    TraderState = Spawn(class'TA_State');
    if (TraderState == None)
    {
        `Log("TraderAnywhere: unable to spawn replicated trader state");
        Destroy();
        return;
    }

    SetTimer(0.25, true, nameof(UpdateTraderState));
    UpdateTraderState();
    `Log("TraderAnywhere: v0.1.0 runtime initialized");
}

function UpdateTraderState()
{
    local KFGameReplicationInfo KFGRI;
    local bool bShouldOpen;

    if (TraderState == None || TraderState.bDeleteMe)
    {
        return;
    }

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    bShouldOpen = KFGameInfo_Survival(WorldInfo.Game) != None
        && KFGRI != None
        && KFGRI.bTradersEnabled
        && KFGRI.bTraderIsOpen;

    TraderState.SetAllTradersOpen(bShouldOpen);
    EnsureRemoteUseTriggers();
}

function EnsureRemoteUseTriggers()
{
    local KFPlayerController KFPC;
    local TA_UseTrigger UseTrigger;
    local bool bFound;

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        if (KFPC.Pawn == None || !KFPC.Pawn.IsAliveAndWell())
        {
            continue;
        }

        bFound = false;
        foreach WorldInfo.AllActors(class'TA_UseTrigger', UseTrigger)
        {
            if (!UseTrigger.bDeleteMe && UseTrigger.TrackedPawn == KFPC.Pawn)
            {
                bFound = true;
                break;
            }
        }

        if (!bFound)
        {
            UseTrigger = Spawn(class'TA_UseTrigger', KFPC,, KFPC.Pawn.Location);
            if (UseTrigger != None)
            {
                UseTrigger.InitFor(KFPC);
            }
        }
    }
}

defaultproperties
{
    bNoDelete=false
    RemoteRole=ROLE_None
}
