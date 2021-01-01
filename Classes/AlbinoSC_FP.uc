class AlbinoSC_FP extends KFMutator
	config(AlbinoSC_FP);//by Dr. Smoke


var config bool		bConfigsInit;
var config bool		SpawnwithBoss;
var config float	SpawnCycle;
var config int		FPWave;
var config int		QPWave;
var config int		ScrakeWave;
var config bool		bFuryScrake;
var config bool		bFuryFP;
var config int		SpawnSC;
var config int		SpawnFP;
var config int		SpawnQP;
var config bool		bSpawnAlbino;
var int				CurrentWave;
var bool			bResetDilation;

//The 3 main functions
function InitMutator(string Options, out string ErrorMessage)
			{
				local String CurrentError;
				CurrentError = ErrorMessage;
				super.InitMutator( Options, ErrorMessage );
				`log("******** AlbinoSC_FP Mutator initialized ********");
					if (CurrentError != "")
					{
						`log("******** Error Encountered: ********");
						`log(CurrentError);
						`log("******** Error End ********");
					}
			}
			function AddMutator(Mutator M)
			{
				if (M != Self)
				{
					if (M.Class == Class)
						M.Destroy();
					else
						Super.AddMutator(M);
				}
			} 


function PostBeginPlay()
{
				Super.PostBeginPlay();
				
				if (WorldInfo.Game.BaseMutator == None)
					WorldInfo.Game.BaseMutator = Self;
				else
					WorldInfo.Game.BaseMutator.AddMutator(Self);

	//Checks if there's no config file, then create a new one
	if(!bConfigsInit)
	{
		bConfigsInit = true;
		SpawnCycle = 192.f;
		FPWave = 4;//Spawn FP from FPWave
		QPWave = 2;//Spawn Qp from QPWave
		ScrakeWave = 2;
		bFuryScrake = false;
		bFuryFP = false;
		SpawnSC = 1;//spawn ammount sc
		SpawnFP = 1;//spawn ammount fp
		SpawnQP = 1;//spawn ammount qp
		SaveConfig();
		`log("********** Config File Saved **********");
	}
	
	// Starts a timer for the spawn cycle (All)
	SetTimer(SpawnCycle, true, nameof(SpawnGorilla) );
	
}

	function SpawnGorilla()
	{
		//Declaration of variables used in the function 
		local class<KFPawn_Monster>				KFPawn_M;
		local KFSpawnVolume						SpawnVolume;
		local array< class<KFPawn_Monster> >	FakeSpawnList;
		local byte								i;
		//local KFGameReplicationInfo   			MyKFGRI;
		if(bSpawnAlbino || bFuryFP || bFuryScrake){bFuryScrake=true;bFuryFP=true;bSpawnAlbino=true;}
		
		//Gets the current wave number
			if(MyKFGI.MyKFGRI != None)
			{
				CurrentWave = MyKFGI.MyKFGRI.WaveNum;//Get CurrentWave
			}
		
		//If the trader is still open, reset the timers
		//(if MyKFGRI.IsBossWave() && !SpawnwithBoss) Checks if it's a boss wave (Unusued)
			if(MyKFGI.MyKFGRI.bTraderIsOpen)
			{
				ModifyTimerTimeDilation(nameof(SpawnGorilla), 3.f, self);
				bResetDilation = true;
				return;
			}
		
		//Checks if the QPs should be spawned on the current wave
		if(QPWave <= CurrentWave )
		{
					for(i=0; i<SpawnQP; i++)
					{
						if(bSpawnAlbino && bFuryFP){KFPawn_M = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshpoundMini_Mixer", class'Class') );}
						if(!bSpawnAlbino){KFPawn_M = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshpoundMini", class'Class') );}
						FakeSpawnList.AddItem( KFPawn_M );
					}
			
			QPWave = QPWave + 1;
			//ModifyTimerTimeDilation(nameof(SpawnGorilla), 8.f, self);
			//bResetDilation = true;
		}
		
		//Checks if the FPs should be spawned on the current wave
		if(FPWave <= CurrentWave)
		{
			for(i=0; i<SpawnFP; i++)
			{
				if(bSpawnAlbino){KFPawn_M = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshPound_Versus", class'Class') );}
				if(!bSpawnAlbino){KFPawn_M = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshPound", class'Class') );}
				FakeSpawnList.AddItem( KFPawn_M );
			}
			
			FPWave = FPWave + 1;
		}
		if(ScrakeWave <= CurrentWave )
		{
			for(i=0; i<SpawnSC; i++)
			{
				if(bFuryScrake && bSpawnAlbino)
					{
						KFPawn_M = class<KFPawn_Monster>(DynamicLoadObject("AlbinoSC_FP.KFPawn_EnragedScrake2", class'Class') );//mutatorName.className
					}
			else
					{
						KFPawn_M = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedScrake_Versus", class'Class') );
					}
				FakeSpawnList.AddItem( KFPawn_M );
			}
				ScrakeWave++;
				//ModifyTimerTimeDilation(nameof(SpawnGorilla), 8.f, self);
		}
		SpawnCurrent(FakeSpawnList, SpawnVolume);
		bResetDilation = true;
		if(bResetDilation)
		{
			ResetTimerTimeDilation(nameof(SpawnGorilla), self);
			bResetDilation = false;
		}
	}

function SpawnCurrent(array< class<KFPawn_Monster> > List, KFSpawnVolume SpawnVolume)
{
	if( KFGameInfo(WorldInfo.Game) != None)
	{
		KFGameInfo(WorldInfo.Game).SpawnManager.DesiredSquadType = EST_Large;//set spawn location
		SpawnVolume = KFGameInfo(WorldInfo.Game).SpawnManager.GetBestSpawnVolume( List );
	}
	if(SpawnVolume != None)
    {
		SpawnVolume.SpawnWave(List, true);
    }
}

defaultproperties
{
	bResetDilation=false
}