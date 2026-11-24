// Серверная логика открывания всех кабин и удалённого взаимодействия.
// Отдельный Info нужен для совместимости с Safe Mut Loader.
class W4AT_Server extends Info;

var W4AT_State TraderState;

public event PostBeginPlay()
{
    local W4AT_Server OtherServer;

    Super.PostBeginPlay();

    if (WorldInfo.NetMode == NM_Client)
    {
        return;
    }

    // Не запускаем два независимых таймера, если объект создан повторно.
    foreach WorldInfo.DynamicActors(class'W4AT_Server', OtherServer)
    {
        if (OtherServer != Self && !OtherServer.bDeleteMe)
        {
            Destroy();
            return;
        }
    }

    TraderState = Spawn(class'W4AT_State');
    if (TraderState == None)
    {
        `Log("W4AllTraders: unable to spawn replicated trader state");
        Destroy();
        return;
    }

    SetTimer(0.25, true, nameof(UpdateTraderState));
    UpdateTraderState();
    `Log("W4AllTraders: v0.1.0 runtime initialized");
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
    local W4AT_UseTrigger UseTrigger;
    local bool bFound;

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        if (KFPC.Pawn == None || !KFPC.Pawn.IsAliveAndWell())
        {
            continue;
        }

        bFound = false;
        foreach WorldInfo.AllActors(class'W4AT_UseTrigger', UseTrigger)
        {
            if (!UseTrigger.bDeleteMe && UseTrigger.TrackedPawn == KFPC.Pawn)
            {
                bFound = true;
                break;
            }
        }

        if (!bFound)
        {
            UseTrigger = Spawn(class'W4AT_UseTrigger', KFPC,, KFPC.Pawn.Location);
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
