// Trader Anywhere: точка входа для обычного запуска и Safe Mut Loader.
// Вся логика находится в TA_Server: SML вызывает только совместимые хуки.
class TA_Mutator extends KFMutator;

var private TA_Server Server;

public simulated function bool SafeDestroy()
{
    return (bPendingDelete || bDeleteMe || Destroy());
}

public event PreBeginPlay()
{
    Super.PreBeginPlay();

    if (WorldInfo.NetMode == NM_Client)
    {
        return;
    }

    // Один контроллер даже при повторном добавлении мутатора.
    foreach WorldInfo.DynamicActors(class'TA_Server', Server)
    {
        if (!Server.bDeleteMe)
        {
            break;
        }
        Server = None;
    }

    if (Server == None)
    {
        Server = WorldInfo.Spawn(class'TA_Server');
    }

    if (Server == None)
    {
        `Log("TraderAnywhere: unable to spawn server controller");
        SafeDestroy();
    }
}

public function AddMutator(Mutator Mut)
{
    if (Mut == Self)
    {
        return;
    }

    if (Mut.Class == Class)
    {
        TA_Mutator(Mut).SafeDestroy();
    }
    else
    {
        Super.AddMutator(Mut);
    }
}

// Safe Mut Loader использует это имя, чтобы запустить контроллер вместо
// обычного InitMutator. Для стандартного запуска функция безвредна.
static function string GetLocalString(optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2)
{
    return string(class'TA_Server');
}

defaultproperties
{
    GroupNames(0)="TraderAnywhere"
}
