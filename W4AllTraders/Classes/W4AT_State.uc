// W4 All Traders - replicated phase state.
// Each client animates and enables its own map trader triggers.
class W4AT_State extends ReplicationInfo;

var repnotify bool bAllTradersOpen;

replication
{
    if (Role == ROLE_Authority && bNetDirty)
        bAllTradersOpen;
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();

    // Also handles players joining during an already-open trading phase,
    // and races with the vanilla GRI's ReplicatedEvent notifications.
    SetTimer(0.25, true, nameof(ReconcileTraders));
}

function SetAllTradersOpen(bool bNewValue)
{
    if (Role != ROLE_Authority || bAllTradersOpen == bNewValue)
    {
        return;
    }

    bAllTradersOpen = bNewValue;
    bForceNetUpdate = true;
    ReconcileTraders();

    `Log("W4AllTraders: all pods" @ (bAllTradersOpen ? "open" : "closed"));
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == nameof(bAllTradersOpen))
    {
        ReconcileTraders();
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

simulated function ReconcileTraders()
{
    local KFGameReplicationInfo KFGRI;
    local KFTraderTrigger Trader;
    local bool bTrading;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI == None)
    {
        return;
    }

    bTrading = bAllTradersOpen && KFGRI.bTraderIsOpen;

    foreach WorldInfo.AllActors(class'KFTraderTrigger', Trader)
    {
        // Не считаем невидимые персональные триггеры кабинами карты.
        if (W4AT_UseTrigger(Trader) != None)
        {
            continue;
        }

        if (bTrading && Trader.bEnabled)
        {
            if (!Trader.bOpened)
            {
                Trader.OpenTrader();
            }
        }
        else if (Trader.bOpened && Trader != KFGRI.OpenedTrader)
        {
            // Let vanilla GRI close its chosen pod and trader UI itself.
            Trader.CloseTrader();
        }
    }
}

defaultproperties
{
    bAlwaysRelevant=true
    bOnlyRelevantToOwner=false
    bSkipActorPropertyReplication=false
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=false
}
