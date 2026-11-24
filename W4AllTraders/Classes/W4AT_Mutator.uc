// W4 All Traders: точка входа для обычного запуска и Safe Mut Loader.
// Вся логика находится в W4AT_Server: SML вызывает только совместимые хуки.
class W4AT_Mutator extends KFMutator;

var private W4AT_Server Server;

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
    foreach WorldInfo.DynamicActors(class'W4AT_Server', Server)
    {
        if (!Server.bDeleteMe)
        {
            break;
        }
        Server = None;
    }

    if (Server == None)
    {
        Server = WorldInfo.Spawn(class'W4AT_Server');
    }

    if (Server == None)
    {
        `Log("W4AllTraders: unable to spawn server controller");
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
        W4AT_Mutator(Mut).SafeDestroy();
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
    return string(class'W4AT_Server');
}

defaultproperties
{
    GroupNames(0)="W4AllTraders"
}
