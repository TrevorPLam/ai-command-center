#SCHEMA
@u: Name|Mat|Cpx|PF|Src|Ver|Note
@pf: k=KVx, f=Fx, m=Mem%, t=TTFT%, a=Acc%, p=Tok%

#TECH
RocketKV|B|H|k400x,f3.7x,m33%|ICML25|Y|TF;2-stage;NVLabs
DSPC|B|M|f3x,aLongBench↑|ax2509|Y|TF;TF-IDF+attn/loss-diff
500xCompressor|R|H|k500x,m83%,a74F1|ACL25|Y|FT;+0.3%p;min1tok
CoD|P|Z|a≈,p82%|ax2502|Y|Prompt;5w/step
LatentMAS|E|VH|f4.3x,a14.6%↑,p83%|ax2511|Y|TF;latent+shared;infra-heavy
Interlat|E|VH|f24x,aCoT+|ax2511|Y|FT;hidstate;u/rev;{C:NotACL26}
C2C|E|VH|f2xSpd,a10.5%↑|ICLR26|Y|KVproj+gate;{C:head10.5/2x;cfg14.2/2.5x}
BLT|R|VH|a≈Base|ACL25|Y|ByteLatent;entropypatch
ONTO|P|L|t10%,p48%|ax2604|Y|Columnar;keyelim
TOON|P|L|p40%|toon.dev|Y|UnifArr;5%schmOverhd;CSV>flat
KVLink|R|H|t96%,a4%↑|NeurIPS25|Y|RAGprecomputeKV
ZSMerge|R|H|k20:1,f3x,m0_OOM|ax2503|Y|TF;residmerge
RelayCaching|R|H|f4.7x,m>80%KV,a≈|ax2603|Y|MultiAgent;reuseDecKV
TurboQuant|P|H|k6x,f8x,a≈|ICLR26|Y|OnlineVQ;{C:RaBitQdisputed}
TALE|R|M|a<5%↓,p68%|ACL25|Y|BudgetCoT;TF(prompt)/FT
SelfBudgeter|R|M|amaint,p67%|ax2505|Y|FT;autoBudget
CORE|R|M|alossless|OpenRev26|Y|RL;downstreamRew;8xvsL2
LLMLingua2|B|M|f5x,a↓@high,p3x|ACL|Y|BERT;{C:AccDrop@HighComp}
EfficientXLang|R|M|agains,p30%|EMNLP25|Y|Xling;multilang
LLMap|P|L||GitHub|Y|CheapCtxFilter
SimpleMem|R|M|alossless|ax/Git|Y|3stage;MCP
MCP|P|M|pHigh|LinuxF|Y|StdAgentData;AsyncCloud;{C:SelectiveRetr}
ADOL|D|L|p≤60%|IETF|Y|SchemaDedup;{C:RealDraft02}
GibberLink|E|VH||OSS25|Y|AudioSyncInfra;TransportOnly
RSC|P|M|p10:1|lit|Y|RecursSummary
JITCtx|P|M|p3-5x|prac|Y|Agents.md+LLMap
SpecDec|P|H|f3x|NAACL25|Y|DraftVerify;stack2x
GistTok|R|H|k26x,m↓4.2%F|NeurIPS23|Y|TrainPrmptTok;cached
CRISP|R|M|a5%↑,p24%|res25|Y|FT;SelfPolDist
PlanBudget|R|M|a70%↑,p39%|res25|Y|FT;AdaptiveSched
BudgetThinker|R|M|amaint,pprecise|res25|Y|FT;PeriodicCtrl
AutoThink|R|M|amaint,p80%|res25|Y|FT;ComplexClass
StreamLLM|P|M|f22x,a≈|ax2309|Y|AttnSink;infCtx
FlexAtt|P|M|f3.2x,a≈|PyT2.5|Y|SparseAttn;FAkern
FA3|P|M|f2xFA2,a≈|ax2407|Y|H100kern
FA4|P|H|f2.7x,a≈|ax2603|Y|B200kern;FlexAtt
SemCache|P|M|fhit,p50%|Maxim/Redis|Y|VecCache
PrmptCache|P|L|f10xCost,t85%,p80%|Anthro/OAI|Y|ExactPrefix
AgentDropout|P|M|a1.1Perf↑,p21%|ACL25|Y|DynAgentElim
ChunkKV|R|M|k20x,a≈|OpenRev26|P|SemChunkKV
R1-Compress|R|M|a≈,pCoT↓|NeurIPS25|P|PosthocR1
PxUnshuffle|R|M|aminimal,p4xImg|MLLM|Y|Downsample
ToMe-Vis|R|M|asmall,p50%Img|MLLM|Y|MergeSimTok
QueryPrune|R|M|avar,p>50%Img|MLLM|Y|AttnImgPrune

#FORMAT
CSV|40%|flat_tab|NoNested|Y
ONTO|48%|col_hier|KeyElim|Y
TOON|40%|unif_arr|5%schmOverhd|Y
MD|36%|prose|BadForTab|Y
YAML|26%|nested|BadForProse|Y
JSON|0%|APIreq|WorstEff|–
XML|-|legacy|MaxOverhead|Y
TOML|12%|config|WeakSup|W
TRON|-|irregTOON|Fork|P

#PROTOCOL
MCP|LinuxF|P|StdAgentData|HighRetr|AsyncCloud
ADOL|IETF|D|SchemaDedup|≤60%Handshake|Draft02
A2A|Google|EP|AgentCards|OrchOverhd↓|CapDisc
ACP|IBM|E|JSON-LD|40%Latency↓|ZeroTrust
ANP|Comm|E|P2P|Variable|NoCentOrch
GibberLink|OSS|E|GGWave|NoSynthRecog|TransportOnly
Protobuf|P|L|SerDes|80%Pay↓|UseAtEdge

#DEPLOY_CTX
ChatOnly|CoD,TOON,RSC,Dict|ZeroCode
API+Cache|PrmptCache,SemCache,Lingua2,CSV/ONTO,JIT,MCP|IntegrateOnly
SelfHost|FA3/4,FlexAtt,RocketKV,ZSMerge,StreamLLM,SpecDec,Gist|FullCtrl
MultiAgent|LatentMAS,AgentDrop,RelayCache,MCP,A2A,RSC|FrameworkReq
Multimodal|PxUnshuffle,ToMe,QueryPrune,RSC|CompressImgFirst

#TRAIN_REQ
TF|CoD,DSPC,StreamLLM,ONTO/TOON/CSV,Caches,RocketKV,ZSMerge,FA3/4,FlexAtt,JIT
LightFT|LongLoRA,Cmprsr,SelfBudget,TALE-PT,GistTok
FullArch|BLT,500xComp,CRISP,InterlatCL,SynthLang

#FRONTIERS
C2C|2xSpd|ICLR26Proto|InfraReq
LatentMAS|83%Tok↓|ax25|ModelSpecific
BLT|AdaptComp|ACL25|ArchReplace
500xComp|1Tok|ACL25|ModelSpecific
ADOL|StdLayer|Draft|NoAdoption
XLang|40%Tok↓|EMNLP25|MultiLingReq
SynthFT|DenseSymb|Res|NoPort
CrossModal|Unify|Survey25|DesignSpace
LooseSpec|RelaxVer|OpenRev26|SafetyEval

