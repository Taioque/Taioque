//+------------------------------------------------------------------+
//| EA_NovoV5_Requotes.mq5 |
//| Copyright 2024, JcTrader |
//| https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "JcTrader"
#property link "https://www.mql5.com"
#property version "5.0" // v5.0 + Sistema de Análise Automática
#property strict

//+------------------------------------------------------------------+
//|
//| CONFIGURAÇÕES DO ROBÔ (EA) |
//+------------------------------------------------------------------+

// --- IDENTIFICAÇÃO E CONTROLE ---
input group "=== CONFIGURAÇÕES DO ROBÔ ==="
input int ManualMagicNumber = 0;
input bool ShowIndicators = false;
input int MaxOrders = 8;
input int MinBarsBetweenTrades = 3;
// --- SISTEMA DE ANÁLISE AUTOMÁTICA DE ESPECIFICAÇÕES ---
input group "=== SISTEMA DE ANÁLISE AUTOMÁTICA ==="
input bool UseAutoSpecsAnalysis = true;
// Ativar análise automática de especificações
input bool AutoApplyConfig = false;
// Aplicar configurações automaticamente

// --- SELEÇÃO DE INDICADORES ---
input group "=== SELEÇÃO DE INDICADORES ==="
enum ENUM_INDICATOR_MODE
{
INDICATOR_RSI_ONLY,
INDICATOR_ICHIMOKU_ONLY,
INDICATOR_BOTH_STRONG,
INDICATOR_RSI_W_ICHIMOKU_FILTER
};
input ENUM_INDICATOR_MODE IndicatorMode = INDICATOR_ICHIMOKU_ONLY;

// --- INVERSÃO DE SINAL ---
input group "=== INVERSÃO DE SINAL ==="
input bool InvertTradeSignal = false;
// --- GERENCIAMENTO DE RISCO UNIVERSAL ---
input group "=== GERENCIAMENTO DE RISCO UNIVERSAL ==="
input double RiskPercent = 1.0;
input bool UseDynamicStopLoss = true;
input int FixedStopLoss = 2226;
input double ATR_Multiplier_SL = 1.8;
input double RiskRewardRatio = 1.3;
// --- PROTECÕES AVANÇADAS (ESTÁTICAS) ---
input group "=== PROTECÕES (ESTÁTICAS) ==="
input bool UseTrailingStop = false;
input int TrailingStopPoints = 421;
input bool UseBreakEven = false;
input int BreakEvenPoints = 2785;
// --- MONITORAMENTO ATIVO (SAÍDA) ---
input group "=== MONITORAMENTO ATIVO (SAÍDA) ==="
enum ENUM_ACTIVE_TS_MODE
{
ACTIVE_TS_DISABLED,
ACTIVE_TS_KIJUN_SEN,
ACTIVE_TS_TENKAN_SEN
};
input ENUM_ACTIVE_TS_MODE ActiveTrailStopMode = ACTIVE_TS_DISABLED;
input string Note_ActiveTS = "Se Kijun ou Tenkan, 'UseTrailingStop' fixo é ignorado.";
enum ENUM_DYNAMIC_TP_MODE
{
DYNAMIC_TP_DISABLED,
DYNAMIC_TP_RSI_OPPOSITE,
DYNAMIC_TP_ICHIMOKU_CROSS
};
input ENUM_DYNAMIC_TP_MODE DynamicTakeProfitMode = DYNAMIC_TP_DISABLED;
input string Note_DynamicTP = "Se RSI ou Ichimoku, 'RiskRewardRatio' é ignorado.";
input bool UsePartialClose = true;
input double PartialClose_RR_Target = 8.2;
input double PartialClose_Percent = 100.0;
input bool PartialClose_MoveToBe = false;
input string Note_Partial = "Se true, 'RiskRewardRatio' e 'DynamicTakeProfitMode' são ignorados para a 1ª saída.";
input string PartialCloseMarker = "(P_OK)";

// --- VIGILANTE DE CAPITAL (EQUITY STOP) ---
input group "=== VIGILANTE DE CAPITAL (PRO) ==="
enum ENUM_WATCHDOG_MODE
{
MODE_WATCHDOG_DISABLED,
MODE_WATCHDOG_STATIC_TARGET,
MODE_WATCHDOG_DYNAMIC_TRAIL
};
input ENUM_WATCHDOG_MODE Watchdog_Mode = MODE_WATCHDOG_DYNAMIC_TRAIL;
input double Watchdog_ProfitPercent_Target = 139.0;
input double Watchdog_Trail_Percent = 29.0;
input bool Watchdog_Use_MaxLoss = true;
input double Watchdog_MaxLoss_Percent = 5.3;
// --- NOVOS RECURSOS DE SEGURANÇA ---
input group "=== PROTEÇÃO CONTRA DRAWDOWN ==="
input double MaxDailyDrawdownPercent = 5.0;
input double MaxTotalDrawdownPercent = 15.0;

// (NOVO) Grupo de filtros de mercado/sessão
input group "=== FILTROS DE MERCADO E SESSÃO ==="
input bool Is24_7_Market = false;
// (NOVO) Marcar 'true' para Cripto ou mercados 24/7
input bool UseTradingSessionFilter = true;
input string TradingSession_Start = "02:00";
input string TradingSession_End = "20:00";
// --- FILTROS AVANÇADOS ---
input group "=== FILTROS DE ENTRADA ==="
input bool UseATR_Filter = false;
input int ATR_Period_Filter = 37;
input double MinATR_Value_Points = 120.0;
enum ENUM_MTF_FILTER_MODE
{
MTF_FILTER_DISABLED,
MTF_FILTER_ICHIMOKU_CLOUD,
MTF_FILTER_ICHIMOKU_KIJUN
};
input ENUM_MTF_FILTER_MODE MtfFilterMode = MTF_FILTER_ICHIMOKU_CLOUD;
input ENUM_TIMEFRAMES HigherTimeframe = PERIOD_H6;
input bool UseTimeFilter = false;
input string StartTime = "09:00";
input string EndTime = "17:00";
// --- FILTRO DE SPREAD E EXECUÇÃO ---
input group "=== FILTRO DE SPREAD E EXECUÇÃO ==="
input bool UseSpreadFilter = true;
input int MaxSpreadPoints = 250;
input double Execution_SimulatedSlippagePoints = 0.5;
// --- RECOVERY DE EXECUÇÃO ---
input group "=== RECOVERY DE EXECUÇÃO (PRO) ==="
input int Recovery_MaxRetries = 3;
input int Recovery_RetryDelayMs = 1000;
input double Recovery_MaxPriceDeviationPoints = 0.5;
// --- CONFIGURAÇÃO DO RSI ---
input group "=== INDICADOR RSI (EXAUSTÃO) ==="
input int RSIPeriod = 25;
input double RSIOverbought = 77.6;
input double RSIOversold = 22.7;
// --- CONFIGURAÇÃO DE DIVERGÊNCIAS ---
input group "=== DIVERGÊNCIAS (EXAUSTÃO) ==="
input int DivergenceLookback = 72;
input double MinDivergenceStrength = 5.0;

// --- CONFIGURAÇÃO DO ICHIMOKU ---
input group "=== INDICADOR ICHIMOKU ==="
input int TenkanPeriod = 9;
input int KijunPeriod = 137;
input int SenkouBPeriod = 129;
//+------------------------------------------------------------------+
//| Sistema de Log Hierárquico |
//+------------------------------------------------------------------+
enum ENUM_LOG_LEVEL {
LOG_LEVEL_ERROR,
LOG_LEVEL_WARNING,
LOG_LEVEL_INFO,
LOG_LEVEL_DEBUG
};
input group "=== SISTEMA DE LOG ==="
input ENUM_LOG_LEVEL LogLevel = LOG_LEVEL_INFO;
void Log(ENUM_LOG_LEVEL level, string message)
{
if(level <= LogLevel)
{
string prefix = "";
switch(level)
{
case LOG_LEVEL_ERROR: prefix = "🚨 ERRO: ";
break;
case LOG_LEVEL_WARNING: prefix = "⚠️ AVISO: "; break;
case LOG_LEVEL_INFO: prefix = "ℹ️ INFO: "; break;
case LOG_LEVEL_DEBUG: prefix = "🔍 DEBUG: "; break;
}
Print(prefix + message);
}
}

//+------------------------------------------------------------------+
//|
//| CÓDIGO MESCLADO DO ARQUIVO: ContractSpecsAnalyzer.mqh (v3.0 Ultra) |
//|
//| INÍCIO DAS ESTRUTURAS E CLASSE DE ANÁLISE DE ESPECIFICAÇÕES |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|
//| Enums para melhor organização |
//+------------------------------------------------------------------+
enum ENUM_RISK_CATEGORY
{
RISK_VERY_LOW = 0, // Baixíssimo risco
RISK_LOW = 1, // Baixo risco
RISK_MEDIUM = 2, // Risco médio
RISK_HIGH = 3, // Alto risco
RISK_VERY_HIGH = 4, // Altíssimo risco
RISK_EXTREME = 5 // Risco extremo
};
enum ENUM_TRADING_HOURS_TYPE
{
TRADING_HOURS_24_5 = 0, // 24h 5 dias
TRADING_HOURS_24_7 = 1, // 24h 7 dias
TRADING_HOURS_LIMITED = 2,// Horários limitados
TRADING_HOURS_SESSION = 3 // Por sessões
};
enum ENUM_INSTRUMENT_FAMILY
{
FAMILY_FOREX = 0,
FAMILY_CRYPTO = 1,
FAMILY_INDICES = 2,
FAMILY_COMMODITIES = 3,
FAMILY_STOCKS = 4,
FAMILY_BONDS = 5,
FAMILY_ETFS = 6,
FAMILY_FUTURES = 7,
FAMILY_OPTIONS = 8,
FAMILY_UNKNOWN = 9
};
//+------------------------------------------------------------------+
//| Estrutura avançada para especificações do contrato |
//+------------------------------------------------------------------+
struct ContractSpecs
{
string symbol;
string sector;
string instrumentType;
ENUM_INSTRUMENT_FAMILY family;
long digits;
double contractSize;
string marginCurrency;
string profitCurrency;
string calculationType;
double minVolume;
double maxVolume;
double volumeStep;
double buySwap;
double sellSwap;
long stopLevel;
double marginHedge;
double marginInitial;
double marginMaintenance;
string executionType;
string fillPolicy;
bool is24hTrading;
bool is24hQuotes;
double tickSize;
double tickValue;
double point;
double spread;
double spreadFloat;
double leverage;
ENUM_TRADING_HOURS_TYPE hoursType;
datetime lastUpdate;
bool isTradeAllowed;
bool isCloseAllowed;
bool isShortAllowed;
bool isHedgeAllowed;
double typicalSpread;
double averageVolatility;
string detectedPattern;
string confidenceLevel;
// Construtor
ContractSpecs()
{
symbol = "";
sector = "";
instrumentType = "";
family = FAMILY_UNKNOWN;
digits = 2;
contractSize = 1.0;
marginCurrency = "";
profitCurrency = "";
calculationType = "";
minVolume = 0.01;
maxVolume = 100.0;
volumeStep = 0.01;
buySwap = 0.0;
sellSwap = 0.0;
stopLevel = 0;
marginHedge = 100.0;
marginInitial = 0.0;
marginMaintenance = 0.0;
executionType = "";
fillPolicy = "";
is24hTrading = false;
is24hQuotes = false;
tickSize = 0.0;
tickValue = 0.0;
point = 0.0;
spread = 0.0;
spreadFloat = 0.0;
leverage = 100.0;
hoursType = TRADING_HOURS_LIMITED;
lastUpdate = 0;
isTradeAllowed = false;
isCloseAllowed = false;
isShortAllowed = false;
isHedgeAllowed = false;
typicalSpread = 0.0;
averageVolatility = 0.0;
detectedPattern = "";
confidenceLevel = "BAIXA";
}
};

//+------------------------------------------------------------------+
//| Estrutura para padrões detectados |
//+------------------------------------------------------------------+
struct DetectionPattern
{
string patternName;
ENUM_INSTRUMENT_FAMILY family;
string sector;
string instrumentType;
double confidence;
string description;
};

//+------------------------------------------------------------------+
//|
//|
//| Classe principal do analisador - VERSÃO 3.0 ULTRA |
//+------------------------------------------------------------------+
class ContractSpecsAnalyzer
{
private:
string m_currentSymbol;
ContractSpecs m_specs;
double m_accountBalance;
bool m_verbose;
// Banco de dados de padrões conhecidos
DetectionPattern m_patterns[100];
int m_patternCount;
// Estrutura simples para cache
struct CacheEntry
{
string symbol;
ContractSpecs specs;
datetime lastUpdate;

CacheEntry()
{
symbol = "";
lastUpdate = 0;
}

bool IsExpired() const { return (TimeCurrent() - lastUpdate) > 300;
}
};

CacheEntry m_cache[50];
int m_cacheSize;
// Função de log avançada
void LogMessage(string message, bool isError = false)
{
string prefix = isError ?
"ERRO: " : "ANÁLISE: ";
if(m_verbose || isError)
{
Print(prefix + message);
}
}

// Inicializar banco de padrões
void InitializePatterns()
{
m_patternCount = 0;
// Padrões Forex
AddPattern("FOREX_MAJOR", FAMILY_FOREX, "Forex", "Forex Major", 0.95, "Par de moedas major (6 caracteres, moedas tradicionais)");
AddPattern("FOREX_MINOR", FAMILY_FOREX, "Forex", "Forex Minor", 0.90, "Par de moedas minor");
AddPattern("FOREX_EXOTIC", FAMILY_FOREX, "Forex", "Forex Exótico", 0.85, "Par de moedas com pelo menos uma moeda exótica");
// Padrões Crypto
AddPattern("CRYPTO_MAJOR", FAMILY_CRYPTO, "Cripto", "Crypto Major", 0.95, "Criptomoeda principal (e.g., BTC, ETH)");
AddPattern("CRYPTO_MINOR", FAMILY_CRYPTO, "Cripto", "Crypto Minor", 0.80, "Criptomoeda de menor capitalização");
// Padrões Índices
AddPattern("INDICE_MAJOR", FAMILY_INDICES, "Índice", "Índice Major", 0.95, "Índice de mercado principal (e.g., S&P500, NASDAQ)");
AddPattern("INDICE_FUTURE", FAMILY_FUTURES, "Futuro de Índice", "Futuro de Índice", 0.90, "Contrato Futuro de Índice");
// Padrões Commodities
AddPattern("COMMODITY_METAL", FAMILY_COMMODITIES, "Commodity", "Metal Precioso", 0.95, "Metal precioso (e.g., Ouro, Prata)");
AddPattern("COMMODITY_ENERGY", FAMILY_COMMODITIES, "Commodity", "Energia", 0.90, "Energia (e.g., Petróleo, Gás)");
AddPattern("COMMODITY_AGRO", FAMILY_COMMODITIES, "Commodity", "Agrícola", 0.85, "Agrícola (e.g., Soja, Trigo)");
// Padrões Ações
AddPattern("STOCK_BLUECHIP", FAMILY_STOCKS, "Ação", "Blue Chip", 0.90, "Ação de alta capitalização e liquidez");
AddPattern("STOCK_PENNY", FAMILY_STOCKS, "Ação", "Penny Stock", 0.70, "Ação de baixa capitalização e volatilidade");
}

// Função utilitária para adicionar padrões
void AddPattern(string name, ENUM_INSTRUMENT_FAMILY family, string sector, string type, double confidence, string desc)
{
if(m_patternCount < 100)
{
m_patterns[m_patternCount].patternName = name;
m_patterns[m_patternCount].family = family;
m_patterns[m_patternCount].sector = sector;
m_patterns[m_patternCount].instrumentType = type;
m_patterns[m_patternCount].confidence = confidence;
m_patterns[m_patternCount].description = desc;
m_patternCount++;
}
}

// Utilitário para verificar se um array contém um valor (apenas para strings)
bool ArrayContains(const string &arr[], const string &value) const
{
for(int i = 0; i < ArraySize(arr); i++)
{
if(arr[i] == value) return true;
}
return false;
}

// Utilitário para formatar o nome do símbolo
string CleanSymbolName(string symbol) const
{
string cleanSymbol = StringToUpper(symbol);
StringReplace(cleanSymbol, ".", "");
StringReplace(cleanSymbol, "-", "");
StringReplace(cleanSymbol, "_", "");
StringReplace(cleanSymbol, "!", "");
StringReplace(cleanSymbol, "#", "");
StringReplace(cleanSymbol, "m", "");
// Mínimo
StringReplace(cleanSymbol, "f", "");
// Futuro
return cleanSymbol;
}

// Calcular probabilidade de ser Forex
double CalculateForexProbability(string cleanSymbol) const
{
double confidence = 0.0;
int len = StringLen(cleanSymbol);

// Padrão de 6 caracteres (XXX/YYY)
if(len == 6)
{
string base = StringSubstr(cleanSymbol, 0, 3);
string quote = StringSubstr(cleanSymbol, 3, 3);

// Lista de moedas tradicionais
string majorCurrencies[] = {"USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD"};
string exoticCurrencies[] = {"MXN", "ZAR", "TRY", "RUB", "BRL", "CNY", "INR", "KRW"};

bool baseMajor = ArrayContains(majorCurrencies, base);
bool quoteMajor = ArrayContains(majorCurrencies, quote);
bool baseExotic = ArrayContains(exoticCurrencies, base);
bool quoteExotic = ArrayContains(exoticCurrencies, quote);
if(baseMajor && quoteMajor)
confidence = 0.95;
// Major
else if((baseMajor && quoteExotic) || (baseExotic && quoteMajor))
confidence = 0.85;
// Exotic
else if(baseMajor || quoteMajor)
confidence = 0.70;
// Minor
}

// Propriedade Digits (Forex tipicamente 4 ou 5)
if(m_specs.digits >= 4 && m_specs.digits <= 5)
confidence += 0.1;
// Tamanho do contrato (Forex tipicamente 100000 ou 10000)
if(m_specs.contractSize == 100000.0)
confidence += 0.2;
else if(m_specs.contractSize == 10000.0)
confidence += 0.1;
return MathMin(confidence, 1.0);
}

// Calcular probabilidade de ser Criptomoeda
double CalculateCryptoProbability(string cleanSymbol) const
{
double confidence = 0.0;
// Padrões de nomes (BTCUSD, ETHUSD, XRP...)
string cryptoNames[] = {"BTC", "ETH", "XRP", "LTC", "DOGE", "SOL", "BNB", "ADA"};
for(int i = 0; i < ArraySize(cryptoNames); i++)
{
if(StringFind(cleanSymbol, cryptoNames[i]) >= 0)
{
confidence = 0.8;
break;
}
}

// Cripto normalmente tem 24/7 trading
if(m_specs.is24hTrading)
confidence += 0.15;
// Volatilidade alta (spreads, ticks)
if(m_specs.averageVolatility > 0.05)
confidence += 0.1;
return MathMin(confidence, 1.0);
}

// Calcular probabilidade de ser Índice
double CalculateIndexProbability(string cleanSymbol) const
{
double confidence = 0.0;
string indexNames[] = {"SPX", "NAS", "DAX", "DJI", "FTSE", "CAC", "NKY"};
for(int i = 0; i < ArraySize(indexNames); i++)
{
if(StringFind(cleanSymbol, indexNames[i]) >= 0)
{
confidence = 0.75;
break;
}
}

// Índices têm horários limitados/sessão (não 24/7)
if(m_specs.hoursType != TRADING_HOURS_24_7 && m_specs.hoursType != TRADING_HOURS_24_5)
confidence += 0.15;
// Ponto decimal baixo (geralmente 0)
if(m_specs.digits <= 2)
confidence += 0.1;
return MathMin(confidence, 1.0);
}

// Calcular probabilidade de ser Commodity
double CalculateCommodityProbability(string cleanSymbol) const
{
double confidence = 0.0;
string commodityNames[] = {"GOLD", "SILVER", "XAU", "XAG", "OIL", "WTI", "BRN", "GAS", "COPPER"};
for(int i = 0; i < ArraySize(commodityNames); i++)
{
if(StringFind(cleanSymbol, commodityNames[i]) >= 0)
{
confidence = 0.85;
break;
}
}

// Metais (XAU/XAG) e energias (OIL) têm características próprias de contrato
if(m_specs.contractSize == 100.0) // Comum para XAUUSD, WTI
confidence += 0.1;
// Horários limitados ou sessões
if(m_specs.hoursType != TRADING_HOURS_24_7)
confidence += 0.1;
return MathMin(confidence, 1.0);
}

// Calcular probabilidade de ser Ação/Outros
double CalculateStockProbability(string cleanSymbol) const
{
double confidence = 0.0;
// Nomes curtos (tickers)
if(StringLen(cleanSymbol) >= 2 && StringLen(cleanSymbol) <= 5)
confidence += 0.2;
// Símbolos com sufixos comuns (.US, #, etc)
if(StringFind(m_currentSymbol, ".") > 0 || StringFind(m_currentSymbol, "#") > 0)
confidence += 0.15;
// Horários limitados (sessões de bolsa)
if(m_specs.hoursType == TRADING_HOURS_SESSION || m_specs.hoursType == TRADING_HOURS_LIMITED)
confidence += 0.15;
// Tamanho de contrato 1.0 é comum para ações
if(m_specs.contractSize == 1.0)
confidence += 0.1;
return MathMin(confidence, 1.0);
}

// Função utilitária para obter nível de confiança
string GetConfidenceLevel(double score) const
{
if(score >= 0.95) return "MUITO ALTA";
if(score >= 0.85) return "ALTA";
if(score >= 0.70) return "MÉDIA";
if(score >= 0.50) return "BAIXA";
return "MUITO BAIXA";
}

// Analisar o instrumento com lógica avançada
void DeepAnalysis()
{
string cleanSymbol = CleanSymbolName(m_currentSymbol);
// 1. Calcular scores
double scores[5];
// Forex, Crypto, Indices, Commodities, Stocks
string types[] = {"Forex", "Criptomoeda", "Índice", "Commodity", "Ação"};
scores[0] = CalculateForexProbability(cleanSymbol);
scores[1] = CalculateCryptoProbability(cleanSymbol);
scores[2] = CalculateIndexProbability(cleanSymbol);
scores[3] = CalculateCommodityProbability(cleanSymbol);
scores[4] = CalculateStockProbability(cleanSymbol);
// 2. Encontrar o melhor score
double bestScore = 0.0;
int bestIndex = -1;

for(int i = 0; i < ArraySize(scores); i++)
{
if(scores[i] > bestScore)
{
bestScore = scores[i];
bestIndex = i;
}
}

// 3. Aplicar resultados
if(bestScore > 0.4)
{
m_specs.sector = types[bestIndex];
m_specs.instrumentType = "Detectado Automaticamente";
m_specs.confidenceLevel = GetConfidenceLevel(bestScore);
m_specs.detectedPattern = "DEEP_ANALYSIS";
// Determinar família
switch(bestIndex)
{
case 0: m_specs.family = FAMILY_FOREX;
break;
case 1: m_specs.family = FAMILY_CRYPTO; break;
case 2: m_specs.family = FAMILY_INDICES; break;
case 3: m_specs.family = FAMILY_COMMODITIES; break;
case 4: m_specs.family = FAMILY_STOCKS; break;
default: m_specs.family = FAMILY_UNKNOWN; break;
}

LogMessage("Deep Analysis: Instrumento detectado como " + m_specs.sector + " com confiança " + (string)(bestScore * 100) + "%");
}
else
{
m_specs.family = FAMILY_UNKNOWN;
m_specs.sector = "Não Detectado";
m_specs.instrumentType = "Não Detectado";
LogMessage("Deep Analysis: Não foi possível detectar o instrumento com confiança suficiente.");
}

// 4. Corrigir detalhes com base na família
if(m_specs.family == FAMILY_FOREX)
{
m_specs.leverage = CalculateForexLeverage();
m_specs.hoursType = AnalyzeTradingHours() ? TRADING_HOURS_24_5 : TRADING_HOURS_LIMITED;
}
else if(m_specs.family == FAMILY_CRYPTO)
{
m_specs.hoursType = TRADING_HOURS_24_7;
}
else if(m_specs.family == FAMILY_INDICES || m_specs.family == FAMILY_COMMODITIES || m_specs.family == FAMILY_STOCKS)
{
m_specs.hoursType = AnalyzeTradingHours() ?
TRADING_HOURS_SESSION : TRADING_HOURS_LIMITED;
}
}

// Obter especificação do símbolo do terminal - CORRIGIDO
bool FetchSymbolSpecs()
{
m_specs.symbol = m_currentSymbol;
// CORRETO - SymbolInfoInteger com retorno direto
m_specs.digits = SymbolInfoInteger(m_currentSymbol, SYMBOL_DIGITS);
// CORRETO - SymbolInfoDouble com retorno direto
SymbolInfoDouble(m_currentSymbol, SYMBOL_TRADE_CONTRACT_SIZE, m_specs.contractSize);
// CORRETO - SymbolInfoString
m_specs.marginCurrency = SymbolInfoString(m_currentSymbol, SYMBOL_CURRENCY_MARGIN);
m_specs.profitCurrency = SymbolInfoString(m_currentSymbol, SYMBOL_CURRENCY_PROFIT);
// Cálculo mode
long calcMode = SymbolInfoInteger(m_currentSymbol, SYMBOL_TRADE_CALC_MODE);
m_specs.calculationType = (string)(long)calcMode;
// Volumes
SymbolInfoDouble(m_currentSymbol, SYMBOL_VOLUME_MIN, m_specs.minVolume);
SymbolInfoDouble(m_currentSymbol, SYMBOL_VOLUME_MAX, m_specs.maxVolume);
SymbolInfoDouble(m_currentSymbol, SYMBOL_VOLUME_STEP, m_specs.volumeStep);

// Swaps
SymbolInfoDouble(m_currentSymbol, SYMBOL_SWAP_LONG, m_specs.buySwap);
SymbolInfoDouble(m_currentSymbol, SYMBOL_SWAP_SHORT, m_specs.sellSwap);

// Stop level
m_specs.stopLevel = SymbolInfoInteger(m_currentSymbol, SYMBOL_TRADE_STOPS_LEVEL);
// Margens
SymbolInfoDouble(m_currentSymbol, SYMBOL_MARGIN_HEDGED, m_specs.marginHedge);
SymbolInfoDouble(m_currentSymbol, SYMBOL_MARGIN_INITIAL, m_specs.marginInitial);
SymbolInfoDouble(m_currentSymbol, SYMBOL_MARGIN_MAINTENANCE, m_specs.marginMaintenance);

// Preços e ticks
SymbolInfoDouble(m_currentSymbol, SYMBOL_TRADE_TICK_SIZE, m_specs.tickSize);
SymbolInfoDouble(m_currentSymbol, SYMBOL_TRADE_TICK_VALUE, m_specs.tickValue);
SymbolInfoDouble(m_currentSymbol, SYMBOL_POINT, m_specs.point);

// Spread
long spread_value = SymbolInfoInteger(m_currentSymbol, SYMBOL_SPREAD);
m_specs.spread = (double)spread_value * m_specs.point;

SymbolInfoDouble(m_currentSymbol, SYMBOL_SPREAD_FLOAT, m_specs.spreadFloat);

// Execução
long execution_mode = SymbolInfoInteger(m_currentSymbol, SYMBOL_TRADE_EXEMODE);
switch(execution_mode)
{
case SYMBOL_TRADE_EXECUTION_REQUEST: m_specs.executionType = "Request";
break;
case SYMBOL_TRADE_EXECUTION_INSTANT: m_specs.executionType = "Instant"; break;
case SYMBOL_TRADE_EXECUTION_MARKET: m_specs.executionType = "Market"; break;
case SYMBOL_TRADE_EXECUTION_EXCHANGE: m_specs.executionType = "Exchange"; break;
default: m_specs.executionType = "Desconhecido"; break;
}

// Trade mode - CORRIGIDO
long trade_mode = SymbolInfoInteger(m_currentSymbol, SYMBOL_TRADE_MODE);
switch(trade_mode)
{
case SYMBOL_TRADE_MODE_DISABLED:
m_specs.isTradeAllowed = false;
m_specs.isCloseAllowed = false;
m_specs.isShortAllowed = false;
break;
case SYMBOL_TRADE_MODE_LONGONLY:
m_specs.isTradeAllowed = true;
m_specs.isCloseAllowed = true;
m_specs.isShortAllowed = false;
break;
case SYMBOL_TRADE_MODE_SHORTONLY:
m_specs.isTradeAllowed = true;
m_specs.isCloseAllowed = true;
m_specs.isShortAllowed = true;
break;
case SYMBOL_TRADE_MODE_CLOSEONLY:
m_specs.isTradeAllowed = false;
m_specs.isCloseAllowed = true;
m_specs.isShortAllowed = true;
break;
case SYMBOL_TRADE_MODE_FULL:
default:
m_specs.isTradeAllowed = true;
m_specs.isCloseAllowed = true;
m_specs.isShortAllowed = true;
break;
}

// Hedge mode - CORRIGIDO: verificado via conta
m_specs.isHedgeAllowed = AccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;
m_specs.is24hTrading = true;
m_specs.is24hQuotes = true;
m_specs.lastUpdate = TimeCurrent();
m_specs.typicalSpread = m_specs.spreadFloat;
m_specs.averageVolatility = CalculateAverageVolatility();

return m_specs.isTradeAllowed;
}

// MOCK para Volatilidade Média
double CalculateAverageVolatility()
{
MqlRates rates[];
if(CopyRates(_Symbol, PERIOD_H1, 0, 100, rates) < 100) return 0.0;

double total_range = 0.0;
for(int i = 0; i < 99; i++)
{
total_range += (rates[i].high - rates[i].low);
}
double current_price = 0.0;
if(!SymbolInfoDouble(m_currentSymbol, SYMBOL_ASK, current_price))
{
return 0.0;
}
if(current_price == 0) return 0.0;
return (total_range / 99.0) * 100.0 / current_price;
}

// Calcula alavancagem efetiva (se for Forex)
double CalculateForexLeverage()
{
double margin = m_specs.marginInitial;
double contract = m_specs.contractSize;
double price = 0.0;
if(!SymbolInfoDouble(m_currentSymbol, SYMBOL_ASK, price))
{
return 100.0;
// Retorna padrão
}
if(margin > 0 && contract > 0 && price > 0)
return (price * contract) / margin;
return 100.0;
}

// Analisar se há pregão 24h ou por sessões
bool AnalyzeTradingHours()
{
if(m_specs.family == FAMILY_CRYPTO) return true;
int sessions = 0;
for(int i = 0; i < 7; i++)
{
if(HasTradingSession((ENUM_DAY_OF_WEEK)i)) sessions++;
}
return sessions >= 5;
}

// Função auxiliar para verificar se há sessão de negociação - CORRIGIDO
bool HasTradingSession(ENUM_DAY_OF_WEEK day)
{
datetime session_start, session_end;
// CORRIGIDO: Adicionado o parâmetro 'index' (uint) faltante
if(SymbolInfoSessionTrade(m_currentSymbol, day, 0, session_start, session_end))
{
return session_start != 0;
}
return false;
}

// Funções utilitárias para conversão de Enums em String (para PrintSpecs)
string TradingHoursTypeToString(ENUM_TRADING_HOURS_TYPE hoursType)
{
switch(hoursType)
{
case TRADING_HOURS_24_5: return "24h 5 Dias";
case TRADING_HOURS_24_7: return "24h 7 Dias";
case TRADING_HOURS_LIMITED: return "Horários Limitados";
case TRADING_HOURS_SESSION: return "Por Sessões";
default: return "Desconhecido";
}
}

string RiskCategoryToString(ENUM_RISK_CATEGORY riskCategory)
{
switch(riskCategory)
{
case RISK_VERY_LOW: return "MUITO BAIXO";
case RISK_LOW: return "BAIXO";
case RISK_MEDIUM: return "MÉDIO";
case RISK_HIGH: return "ALTO";
case RISK_VERY_HIGH: return "MUITO ALTO";
case RISK_EXTREME: return "EXTREMO";
default: return "DESCONHECIDO";
}
}

string FamilyToString(ENUM_INSTRUMENT_FAMILY family)
{
switch(family)
{
case FAMILY_FOREX: return "Forex";
case FAMILY_CRYPTO: return "Criptomoeda";
case FAMILY_INDICES: return "Índices";
case FAMILY_COMMODITIES: return "Commodities";
case FAMILY_STOCKS: return "Ações";
case FAMILY_BONDS: return "Títulos";
case FAMILY_ETFS: return "ETFs";
case FAMILY_FUTURES: return "Futuros";
case FAMILY_OPTIONS: return "Opções";
case FAMILY_UNKNOWN: return "Desconhecido";
default: return "Desconhecido";
}
}


public:
// Construtor
ContractSpecsAnalyzer(bool verbose = false)
{
m_verbose = verbose;
m_accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
m_cacheSize = 0;

// Inicializar cache
for(int i = 0; i < 50; i++)
{
m_cache[i] = CacheEntry();
}

// Inicializar banco de padrões
InitializePatterns();
LogMessage("ContractSpecsAnalyzer ULTRA inicializado - Detecção Universal Ativada");
}

// Destrutor
~ContractSpecsAnalyzer()
{
// Limpeza (se necessário)
}

// Método principal para obter as especificações
ContractSpecs GetSpecs(string symbol, bool forceUpdate = false)
{
m_currentSymbol = symbol;
// 1. Verificar Cache
for(int i = 0; i < m_cacheSize; i++)
{
if(m_cache[i].symbol == symbol && !m_cache[i].IsExpired() && !forceUpdate)
{
LogMessage("Cache hit para " + symbol + ". Usando dados cacheados.");
return m_cache[i].specs;
}
}

LogMessage("Analisando especificações para " + symbol + "...");
// 2. Coletar dados do terminal
if(!FetchSymbolSpecs())
{
LogMessage("Não foi possível obter especificações do símbolo " + symbol + ". Trading não permitido.", true);
return m_specs;
}

// 3. Análise Profunda
DeepAnalysis();
// 4. Adicionar ao Cache
if(m_cacheSize < 50)
{
m_cache[m_cacheSize].symbol = symbol;
m_cache[m_cacheSize].specs = m_specs;
m_cache[m_cacheSize].lastUpdate = TimeCurrent();
m_cacheSize++;
}

return m_specs;
}

// Método para imprimir as especificações (debug)
void PrintSpecs(const ContractSpecs &specs)
{
LogMessage("=== Especificações do Contrato: " + specs.symbol + " ===");
LogMessage(" Setor/Tipo: " + specs.sector + " / " + FamilyToString(specs.family) + " (" + specs.instrumentType + ")");
LogMessage(" Confiança: " + specs.confidenceLevel + " (" + specs.detectedPattern + ")");
LogMessage(" Tamanho Contrato: " + (string)specs.contractSize + ", Alavancagem Estimada: " + (string)specs.leverage);
LogMessage(" Volume Min/Max/Step: " + (string)specs.minVolume + " / " + (string)specs.maxVolume + " / " + (string)specs.volumeStep);
LogMessage(" Spread Atual: " + (string)(specs.spread / specs.point) + " pontos, Típico: " + (string)(specs.typicalSpread / specs.point) + " pontos");
LogMessage(" Stop Level: " + (string)specs.stopLevel + " pontos, Volatilidade: " + DoubleToString(specs.averageVolatility, 2) + "%");
LogMessage(" Horário: " + TradingHoursTypeToString(specs.hoursType) + " (24h Trading: " + (specs.is24hTrading ? "true" : "false") + ")");
LogMessage("=====================================");
}

// Método para aplicar configurações automáticas (Placeholder/MOCK)
void ApplyConfig(const ContractSpecs &specs)
{
LogMessage("APLICAÇÃO: Configurações automáticas aplicadas com base na análise de " + specs.sector);
}
};

//+------------------------------------------------------------------+
//| FIM DAS ESTRUTURAS E CLASSE ContractSpecsAnalyzer |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Monitor de Performance |
//+------------------------------------------------------------------+
class CPerformanceMonitor
{
private:
ulong m_startTime;
string m_operationName;

public:
void Start(string opName)
{
m_operationName = opName;
m_startTime = GetMicrosecondCount();
}

void Stop()
{
ulong duration = GetMicrosecondCount() - m_startTime;
if(duration > 1000)
{
Log(LOG_LEVEL_DEBUG, "PERFORMANCE: " + m_operationName + " - " + (string)duration + " μs");
}
}
};

//+------------------------------------------------------------------+
//| Utilitários para Double Seguros |
//+------------------------------------------------------------------+
bool IsEqual(double a, double b, double epsilon = 0.000001)
{
return MathAbs(a - b) < epsilon;
}

bool IsGreater(double a, double b, double epsilon = 0.000001)
{
return (a - b) > epsilon;
}

bool IsLess(double a, double b, double epsilon = 0.000001)
{
return (b - a) > epsilon;
}

bool IsGreaterOrEqual(double a, double b) { return (a > b) || IsEqual(a, b);
}
bool IsLessOrEqual(double a, double b) { return (a < b) || IsEqual(a, b); }

//+------------------------------------------------------------------+
//|
//|
//| Cache de Valores do Símbolo para Performance |
//+------------------------------------------------------------------+
struct SSymbolCache {
double point;
double tick_value;
double tick_size;
long stops_level;
double min_volume;
double max_volume;
double volume_step;
double ask;
double bid;
double spread;
};

SSymbolCache symCache;

void UpdateSymbolCache()
{
static datetime last_update = 0;
if(TimeCurrent() - last_update > 1)
{
SymbolInfoDouble(_Symbol, SYMBOL_POINT, symCache.point);
SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE, symCache.tick_value);
SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE, symCache.tick_size);
symCache.stops_level = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN, symCache.min_volume);
SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX, symCache.max_volume);
SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP, symCache.volume_step);
SymbolInfoDouble(_Symbol, SYMBOL_ASK, symCache.ask);
SymbolInfoDouble(_Symbol, SYMBOL_BID, symCache.bid);

long spread_value = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
symCache.spread = (double)spread_value * symCache.point;

last_update = TimeCurrent();
}
}

//+------------------------------------------------------------------+
//| Classe de Cache de Indicadores Otimizada |
//+------------------------------------------------------------------+
class CIndicatorCache
{
private:
double m_rsiValues[];
double m_tenkanValues[];
double m_kijunValues[];
double m_atrValues[];
datetime m_lastBarTime;
int m_cacheSize;
public:
CIndicatorCache(int cacheSize = 50)
{
m_cacheSize = cacheSize;
ArrayResize(m_rsiValues, cacheSize);
ArrayResize(m_tenkanValues, cacheSize);
ArrayResize(m_kijunValues, cacheSize);
ArrayResize(m_atrValues, cacheSize);
ArrayInitialize(m_rsiValues, 0.0);
ArrayInitialize(m_tenkanValues, 0.0);
ArrayInitialize(m_kijunValues, 0.0);
ArrayInitialize(m_atrValues, 0.0);
m_lastBarTime = 0;
}

bool ShouldUpdate()
{
datetime currentBar = iTime(_Symbol, _Period, 0);
return (currentBar != m_lastBarTime);
}

void SetUpdated() { m_lastBarTime = iTime(_Symbol, _Period, 0);
}

bool UpdateRSIValues(int handle, int count = 5)
{
if(count > m_cacheSize) count = m_cacheSize;
if(CopyBuffer(handle, 0, 0, count, m_rsiValues) == count)
{
return true;
}
return false;
}

bool UpdateIchimokuValues(int handle, int count = 3)
{
if(count > m_cacheSize) count = m_cacheSize;
if(CopyBuffer(handle, 0, 0, count, m_tenkanValues) == count &&
CopyBuffer(handle, 1, 0, count, m_kijunValues) == count)
{
return true;
}
return false;
}

bool UpdateATRValues(int handle, int count = 3)
{
if(count > m_cacheSize) count = m_cacheSize;
if(CopyBuffer(handle, 0, 0, count, m_atrValues) == count)
{
return true;
}
return false;
}

double GetRSIValue(int index = 1)
{
if(index >= 0 && index < m_cacheSize)
return m_rsiValues[index];
return 0.0;
}

double GetTenkanValue(int index = 1)
{
if(index >= 0 && index < m_cacheSize)
return m_tenkanValues[index];
return 0.0;
}

double GetKijunValue(int index = 1)
{
if(index >= 0 && index < m_cacheSize)
return m_kijunValues[index];
return 0.0;
}

double GetATRValue(int index = 1)
{
if(index >= 0 && index < m_cacheSize)
return m_atrValues[index];
return 0.0;
}

bool IsValid() { return (m_lastBarTime > 0); }
};

//+------------------------------------------------------------------+
//|
//|
//| Classe de Gerenciamento de Recovery Otimizada |
//+------------------------------------------------------------------+
class CRecoveryManager
{
private:
struct SOrderAttempt {
ulong ticket;
MqlTradeRequest request;
datetime firstAttempt;
int attemptCount;
double originalPrice;
};

SOrderAttempt m_attempts[];
int m_maxRetries;
int m_retryDelay;
double m_maxPriceDeviation;

double GetRequestPrice(const MqlTradeRequest &request) const
{
if(request.action == TRADE_ACTION_DEAL)
{
if(request.type == ORDER_TYPE_BUY) return symCache.ask;
if(request.type == ORDER_TYPE_SELL) return symCache.bid;
}
return request.price;
}

double GetCurrentPrice(ENUM_ORDER_TYPE orderType) const
{
return (orderType == ORDER_TYPE_BUY) ?
symCache.ask : symCache.bid;
}

void UpdateRequestPrices(MqlTradeRequest &request)
{
if(request.type == ORDER_TYPE_BUY)
{
request.price = symCache.ask;
if(request.tp > 0) request.tp = NormalizeDouble(request.tp, _Digits);
if(request.sl > 0) request.sl = NormalizeDouble(request.sl, _Digits);
}
else if(request.type == ORDER_TYPE_SELL)
{
request.price = symCache.bid;
if(request.tp > 0) request.tp = NormalizeDouble(request.tp, _Digits);
if(request.sl > 0) request.sl = NormalizeDouble(request.sl, _Digits);
}
}

void UpdateRequestPrice(MqlTradeRequest &request, double newPrice)
{
request.price = newPrice;
request.deviation = 0;
}

int FindAttempt(long magic, string symbol)
{
for(int i = 0; i < ArraySize(m_attempts); i++)
{
if(m_attempts[i].request.magic == magic && m_attempts[i].request.symbol == symbol)
return i;
}
return -1;
}

void AddAttempt(const SOrderAttempt &attempt)
{
int size = ArraySize(m_attempts);
ArrayResize(m_attempts, size + 1);
m_attempts[size] = attempt;
}

void RemoveAttempt(long magic, string symbol)
{
int index = FindAttempt(magic, symbol);
if(index != -1)
{
ArrayRemove(m_attempts, index, 1);
}
}

public:
CRecoveryManager(int maxRetries = 3, int retryDelayMs = 1000, double maxDeviationPrice = 0.0005)
{
m_maxRetries = maxRetries;
m_retryDelay = retryDelayMs;
m_maxPriceDeviation = maxDeviationPrice * symCache.point;
ArrayResize(m_attempts, 0);
}

bool ProcessOrderResult(MqlTradeRequest &request, MqlTradeResult &result, string context)
{
switch(result.retcode)
{
case TRADE_RETCODE_DONE:
Log(LOG_LEVEL_INFO, "SUCESSO " + context + ": Ticket " + (string)result.order);
RemoveAttempt(request.magic, request.symbol);
return true;

case TRADE_RETCODE_REQUOTE:
case TRADE_RETCODE_TIMEOUT:
return HandleRetryableError(request, result, context);
case TRADE_RETCODE_INVALID_PRICE:
case TRADE_RETCODE_INVALID_STOPS:
return HandlePriceError(request, result, context);
case TRADE_RETCODE_NO_MONEY:
Log(LOG_LEVEL_ERROR, "ERRO CRÍTICO " + context + ": Saldo insuficiente");
return false;

case TRADE_RETCODE_MARKET_CLOSED:
Log(LOG_LEVEL_WARNING, "ERRO " + context + ": Mercado fechado");
return false;

case TRADE_RETCODE_TRADE_DISABLED:
Log(LOG_LEVEL_ERROR, "ERRO CRÍTICO " + context + ": Trading desabilitado");
return false;

default:
Log(LOG_LEVEL_ERROR, "ERRO DESCONHECIDO " + context + ": Código " + (string)result.retcode);
return false;
}
}

bool HandleRetryableError(MqlTradeRequest &request, MqlTradeResult &result, string context)
{
int attemptIndex = FindAttempt(request.magic, request.symbol);
SOrderAttempt attempt;

if(attemptIndex == -1)
{
attempt.ticket = 0;
attempt.request = request;
attempt.firstAttempt = TimeCurrent();
attempt.attemptCount = 1;
attempt.originalPrice = GetRequestPrice(request);

AddAttempt(attempt);
Log(LOG_LEVEL_WARNING, "PRIMEIRA TENTATIVA " + context + ": Requote/Timeout, tentando novamente...");
}
else
{
attempt = m_attempts[attemptIndex];
attempt.attemptCount++;

if(attempt.attemptCount > m_maxRetries)
{
Log(LOG_LEVEL_ERROR, "FALHA " + context + ": Número máximo de tentativas excedido (" + (string)m_maxRetries + ")");
RemoveAttempt(request.magic, request.symbol);
return false;
}

Log(LOG_LEVEL_WARNING, "TENTATIVA " + (string)attempt.attemptCount + "/" + (string)m_maxRetries + " " + context + ": Requote/Timeout");
}

UpdateRequestPrices(request);
Sleep(m_retryDelay);
bool sendResult = OrderSend(request, result);
if(sendResult)
{
return ProcessOrderResult(request, result, context + " (Retry)");
}

return false;
}

bool HandlePriceError(MqlTradeRequest &request, MqlTradeResult &result, string context)
{
double currentPrice = GetCurrentPrice(request.type);
double requestedPrice = GetRequestPrice(request);
double priceDiff = MathAbs(currentPrice - requestedPrice);
Log(LOG_LEVEL_WARNING, "ERRO DE PREÇO " + context + ": Solicitado: " + (string)requestedPrice + ", Atual: " + (string)currentPrice + ", Dif: " + (string)priceDiff);
if(priceDiff <= m_maxPriceDeviation)
{
Log(LOG_LEVEL_INFO, "AJUSTANDO PREÇO " + context + ": " + (string)requestedPrice + " -> " + (string)currentPrice);
UpdateRequestPrice(request, currentPrice);

if(ValidateAndAdjustLevels(request))
{
Sleep(m_retryDelay);
bool sendResult = OrderSend(request, result);
if(sendResult)
{
return ProcessOrderResult(request, result, context + " (Price Adjusted)");
}
}
}

Log(LOG_LEVEL_ERROR, "ERRO DE PREÇO IRRECUPERÁVEL " + context + ": Diferença (" + (string)priceDiff + ") > Tolerância (" + (string)m_maxPriceDeviation + ")");
return false;
}

bool ValidateAndAdjustLevels(MqlTradeRequest &request)
{
double entryPrice = GetRequestPrice(request);
double stopsLevel = symCache.stops_level * symCache.point;

if(request.sl > 0)
{
if(request.type == ORDER_TYPE_BUY)
{
if(IsGreaterOrEqual(request.sl, entryPrice - stopsLevel))
{
request.sl = NormalizeDouble(entryPrice - stopsLevel * 1.05, _Digits);
}
}
else if(request.type == ORDER_TYPE_SELL)
{
if(IsLessOrEqual(request.sl, entryPrice + stopsLevel))
{
request.sl = NormalizeDouble(entryPrice + stopsLevel * 1.05, _Digits);
}
}
}

if(request.tp > 0)
{
if(request.type == ORDER_TYPE_BUY)
{
if(IsLessOrEqual(request.tp, entryPrice + stopsLevel))
{
request.tp = NormalizeDouble(entryPrice + stopsLevel * 1.05, _Digits);
}
}
else if(request.type == ORDER_TYPE_SELL)
{
if(IsGreaterOrEqual(request.tp, entryPrice - stopsLevel))
{
request.tp = NormalizeDouble(entryPrice - stopsLevel * 1.05, _Digits);
}
}
}

return true;
}

bool ModifyStopLossWithRecovery(ulong ticket, double sl, double tp = 0.0)
{
MqlTradeRequest request;
MqlTradeResult result;

if(!PositionSelectByTicket(ticket)) return false;

request.action = TRADE_ACTION_SLTP;
request.position = ticket;
request.sl = sl;
if(tp > 0) request.tp = tp;
else request.tp = PositionGetDouble(POSITION_TP);
request.magic = PositionGetInteger(POSITION_MAGIC);
request.symbol = PositionGetString(POSITION_SYMBOL);

bool sendResult = OrderSend(request, result);
if(sendResult)
{
if(result.retcode == TRADE_RETCODE_DONE)
{
Log(LOG_LEVEL_INFO, "MODIFICAÇÃO SUCESSO: Ticket " + (string)ticket + ", Novo SL: " + (string)sl);
return true;
}
else if(result.retcode == TRADE_RETCODE_INVALID_STOPS)
{
Log(LOG_LEVEL_WARNING, "ERRO MODIFICAÇÃO: Stops inválidos para ticket " + (string)ticket + ". Tentando ajuste...");
return AdjustModificationLevels(ticket, request.sl, request.tp);
}
}

Log(LOG_LEVEL_ERROR, "FALHA MODIFICAÇÃO: Ticket " + (string)ticket + ", Código: " + (string)result.retcode);
return false;
}

bool AdjustModificationLevels(ulong ticket, double &sl, double &tp)
{
if(!PositionSelectByTicket(ticket)) return false;
double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
long type = PositionGetInteger(POSITION_TYPE);
double stopsLevel = symCache.stops_level * symCache.point;
if(sl > 0)
{
if(type == POSITION_TYPE_BUY)
{
if(IsGreaterOrEqual(sl, currentPrice - stopsLevel))
{
sl = NormalizeDouble(currentPrice - stopsLevel * 1.05, _Digits);
Log(LOG_LEVEL_INFO, "SL de COMPRA ajustado para: " + (string)sl);
}
}
else if(type == POSITION_TYPE_SELL)
{
if(IsLessOrEqual(sl, currentPrice + stopsLevel))
{
sl = NormalizeDouble(currentPrice + stopsLevel * 1.05, _Digits);
Log(LOG_LEVEL_INFO, "SL de VENDA ajustado para: " + (string)sl);
}
}
}

// Tenta novamente a modificação após ajuste
MqlTradeRequest request;
MqlTradeResult result;

request.action = TRADE_ACTION_SLTP;
request.position = ticket;
request.sl = sl;
request.tp = tp;
request.magic = PositionGetInteger(POSITION_MAGIC);
request.symbol = PositionGetString(POSITION_SYMBOL);
bool sendResult = OrderSend(request, result);
if(sendResult)
{
if(result.retcode == TRADE_RETCODE_DONE)
{
Log(LOG_LEVEL_INFO, "MODIFICAÇÃO SUCESSO APÓS AJUSTE: Ticket " + (string)ticket + ", SL: " + (string)sl);
return true;
}
}

Log(LOG_LEVEL_ERROR, "FALHA FINAL MODIFICAÇÃO APÓS AJUSTE: Ticket " + (string)ticket + ", Código: " + (string)result.retcode);
return false;
}
};

//+------------------------------------------------------------------+
//| Variáveis Globais (EA_NovoV5_Requotes.mq5) |
//+------------------------------------------------------------------+
int rsi_handle;
int ichimoku_handle;
int atr_handle;
int last_trade_bar = 0;
datetime last_bar_time = 0;
long G_MagicNumber;
long G_PartialCloseTickets[];
double G_InitialStopLoss[];
long G_InitialStopLoss_Tickets[];
int htf_ichimoku_handle = INVALID_HANDLE;
int G_Start_HHMM = 0;
int G_End_HHMM = 0;
bool G_Watchdog_Trail_Active = false;
double G_Watchdog_HighWaterMark = 0.0;
double G_InitialBalance = 0.0;
double G_DailyHighBalance = 0.0;
datetime G_DailyResetTime = 0;
CRecoveryManager *recoveryManager = NULL;
CIndicatorCache *indicatorCache = NULL;
CPerformanceMonitor perfMonitor;
//+------------------------------------------------------------------+
//| Variáveis do Sistema de Análise Automática |
//+------------------------------------------------------------------+
ContractSpecsAnalyzer *specsAnalyzer = NULL;

//+------------------------------------------------------------------+
//| Funções de Validação de Inputs |
//+------------------------------------------------------------------+
bool ValidateInputs()
{
Log(LOG_LEVEL_DEBUG, "Iniciando validação de inputs...");
if(RiskPercent <= 0)
{
Log(LOG_LEVEL_ERROR, "RiskPercent deve ser maior que 0");
return false;
}
if(MaxOrders <= 0)
{
Log(LOG_LEVEL_ERROR, "MaxOrders deve ser maior que 0");
return false;
}
if(UseDynamicStopLoss)
{
if(ATR_Multiplier_SL <= 0)
{
Log(LOG_LEVEL_ERROR, "ATR_Multiplier_SL deve ser maior que 0 para SL Dinâmico");
return false;
}
if(RiskRewardRatio <= 0)
{
Log(LOG_LEVEL_ERROR, "RiskRewardRatio deve ser maior que 0 para SL Dinâmico");
return false;
}
}
if(UseAutoSpecsAnalysis)
{
double contract_size = 0.0;
if(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE, contract_size) && contract_size <= 0)
{
Log(LOG_LEVEL_WARNING, "Tamanho do contrato inválido para análise automática. Verifique a corretora.");
}
}
if(UseATR_Filter && MinATR_Value_Points <= 0)
{
Log(LOG_LEVEL_ERROR, "MinATR_Value_Points deve ser positivo");
return false;
}
if(Watchdog_Mode == MODE_WATCHDOG_DYNAMIC_TRAIL && Watchdog_Trail_Percent <= 0)
{
Log(LOG_LEVEL_ERROR, "Watchdog_Trail_Percent deve ser positivo para modo Dynamic Trail");
return false;
}
if(MaxDailyDrawdownPercent < 0 || MaxTotalDrawdownPercent < 0)
{
Log(LOG_LEVEL_ERROR, "Drawdown Percentual não pode ser negativo");
return false;
}
Log(LOG_LEVEL_INFO, "VALIDAÇÃO CONCLUÍDA: Todas as configurações são válidas");
return true;
}

//+------------------------------------------------------------------+
//|
//|
//| Funções de Inicialização em Cascata |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
perfMonitor.Start("InitializeIndicators");
rsi_handle = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE);
if(rsi_handle == INVALID_HANDLE)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Indicador RSI não pode ser inicializado");
perfMonitor.Stop();
return false;
}
ichimoku_handle = iIchimoku(_Symbol, _Period, TenkanPeriod, KijunPeriod, SenkouBPeriod);
if(ichimoku_handle == INVALID_HANDLE)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Indicador Ichimoku não pode ser inicializado");
IndicatorRelease(rsi_handle);
perfMonitor.Stop();
return false;
}
atr_handle = iATR(_Symbol, _Period, ATR_Period_Filter);
if(atr_handle == INVALID_HANDLE)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Indicador ATR não pode ser inicializado");
IndicatorRelease(rsi_handle);
IndicatorRelease(ichimoku_handle);
perfMonitor.Stop();
return false;
}
if(MtfFilterMode != MTF_FILTER_DISABLED)
{
htf_ichimoku_handle = iIchimoku(_Symbol, HigherTimeframe, TenkanPeriod, KijunPeriod, SenkouBPeriod);
if(htf_ichimoku_handle == INVALID_HANDLE)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Indicador Ichimoku MTF não pode ser inicializado");
IndicatorRelease(rsi_handle);
IndicatorRelease(ichimoku_handle);
IndicatorRelease(atr_handle);
perfMonitor.Stop();
return false;
}
}
perfMonitor.Stop();
return true;
}

bool InitializeManagers()
{
perfMonitor.Start("InitializeManagers");
if(recoveryManager == NULL)
{
recoveryManager = new CRecoveryManager(Recovery_MaxRetries, Recovery_RetryDelayMs, Recovery_MaxPriceDeviationPoints);
if(recoveryManager == NULL)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Não foi possível criar Recovery Manager.");
perfMonitor.Stop();
return false;
}
}
perfMonitor.Stop();
return true;
}

bool InitializeCache()
{
perfMonitor.Start("InitializeCache");
if(indicatorCache == NULL)
{
indicatorCache = new CIndicatorCache();
if(indicatorCache == NULL)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Não foi possível criar Indicator Cache.");
perfMonitor.Stop();
return false;
}
}
perfMonitor.Stop();
return true;
}

bool InitializeSpecsAnalyzer()
{
perfMonitor.Start("InitializeSpecsAnalyzer");
if(UseAutoSpecsAnalysis)
{
if(specsAnalyzer == NULL)
{
specsAnalyzer = new ContractSpecsAnalyzer(LogLevel == LOG_LEVEL_DEBUG);
if(specsAnalyzer == NULL)
{
Log(LOG_LEVEL_ERROR, "FALHA CRÍTICA: Não foi possível criar Specs Analyzer.");
perfMonitor.Stop();
return false;
}
}

Log(LOG_LEVEL_INFO, "Analisando especificações do símbolo: " + _Symbol);
ContractSpecs specs = specsAnalyzer->GetSpecs(_Symbol);
specsAnalyzer->PrintSpecs(specs);

if(AutoApplyConfig)
{
Log(LOG_LEVEL_INFO, "APLICAÇÃO AUTOMÁTICA ATIVADA. Ajustando configurações...");
// Lógica de aplicação automática aqui
}
}
perfMonitor.Stop();
return true;
}

//+------------------------------------------------------------------+
//| Função OnInit do Expert |
//+------------------------------------------------------------------+
int OnInit()
{
perfMonitor.Start("OnInit");

// 1. Validar Inputs
if(!ValidateInputs())
{
Log(LOG_LEVEL_ERROR, "Configurações inválidas. EA não pode ser inicializado.");
perfMonitor.Stop();
return(INIT_FAILED);
}

// 2. Inicializar Variáveis Globais e Cache de Símbolo
UpdateSymbolCache();
// Configuração do Magic Number
if(ManualMagicNumber == 0)
{
datetime activation_time = TimeCurrent();
G_MagicNumber = (long)(activation_time + ChartID());
Log(LOG_LEVEL_INFO, "MAGIC NUMBER: Modo Automático. Usando: " + (string)G_MagicNumber);
}
else
{
G_MagicNumber = (long)ManualMagicNumber;
Log(LOG_LEVEL_INFO, "MAGIC NUMBER: Modo Manual. Usando: " + (string)G_MagicNumber);
}

G_InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
G_DailyHighBalance = AccountInfoDouble(ACCOUNT_EQUITY);
MqlDateTime now;
TimeToStruct(TimeCurrent(), now);
now.hour = 0; now.min = 0; now.sec = 0;
G_DailyResetTime = StructToTime(now);
// 3. Inicializar Componentes
if(!InitializeIndicators()) return(INIT_FAILED);
if(!InitializeManagers()) return(INIT_FAILED);
if(!InitializeCache()) return(INIT_FAILED);
if(!InitializeSpecsAnalyzer()) return(INIT_FAILED);
// 4. Configurar Filtros de Tempo
if(UseTimeFilter)
{
datetime start_time = StringToTime(StartTime);
datetime end_time = StringToTime(EndTime);
MqlDateTime start_struct, end_struct;
TimeToStruct(start_time, start_struct);
TimeToStruct(end_time, end_struct);
G_Start_HHMM = start_struct.hour * 100 + start_struct.min;
G_End_HHMM = end_struct.hour * 100 + end_struct.min;
Log(LOG_LEVEL_INFO, "FILTRO DE TEMPO: Ativado entre " + StartTime + " e " + EndTime);
}

// 5. Configurar Filtro de Sessão
if(UseTradingSessionFilter)
{
Log(LOG_LEVEL_INFO, "FILTRO DE SESSÃO: Ativado entre " + TradingSession_Start + " e " + TradingSession_End);
}

// 6. Adicionar Indicadores ao Chart (se ShowIndicators=true)
if(ShowIndicators)
{
ChartIndicatorAdd(0, 0, ichimoku_handle);
ChartIndicatorAdd(0, 1, rsi_handle);
ChartIndicatorAdd(0, 2, atr_handle);
}

Log(LOG_LEVEL_INFO, "=== EA_NovoV5_Requotes.mq5 (v5.0) inicializado com sucesso! ===");
perfMonitor.Stop();
return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Função OnDeinit do Expert |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
Log(LOG_LEVEL_INFO, "=== FINALIZANDO EA - ANÁLISE AUTOMÁTICA ===");
if(rsi_handle != INVALID_HANDLE)
{
IndicatorRelease(rsi_handle);
Log(LOG_LEVEL_INFO, "Handle RSI liberado");
}

if(ichimoku_handle != INVALID_HANDLE)
{
IndicatorRelease(ichimoku_handle);
Log(LOG_LEVEL_INFO, "Handle Ichimoku liberado");
}

if(atr_handle != INVALID_HANDLE)
{
IndicatorRelease(atr_handle);
Log(LOG_LEVEL_INFO, "Handle ATR liberado");
}

if(htf_ichimoku_handle != INVALID_HANDLE)
{
IndicatorRelease(htf_ichimoku_handle);
Log(LOG_LEVEL_INFO, "Handle Ichimoku MTF liberado");
}

ArrayFree(G_PartialCloseTickets);
ArrayFree(G_InitialStopLoss);
ArrayFree(G_InitialStopLoss_Tickets);
if(recoveryManager != NULL)
{
delete recoveryManager;
Log(LOG_LEVEL_INFO, "Recovery Manager liberado");
}

if(indicatorCache != NULL)
{
delete indicatorCache;
Log(LOG_LEVEL_INFO, "Indicator Cache liberado");
}

if(specsAnalyzer != NULL)
{
delete specsAnalyzer;
Log(LOG_LEVEL_INFO, "Specs Analyzer liberado");
}
}

//+------------------------------------------------------------------+
//| (OTIMIZADO) Calcular Tamanho de Lote |
//+------------------------------------------------------------------+
double CalculateLotSize(double sl_points, ENUM_ORDER_TYPE orderType)
{
perfMonitor.Start("CalculateLotSize");

if(IsLessOrEqual(sl_points, 0))
{
Log(LOG_LEVEL_ERROR, "ERRO Lote: Stop Loss em pontos inválido: " + (string)sl_points);
perfMonitor.Stop();
return 0.0;
}

// 1. Calcular o risco monetário
double account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
double risk_amount = account_balance * (RiskPercent / 100.0);

// 2. Calcular o custo do stop loss em moeda da conta (por lote)
double cost_per_lot;
double tick_value = symCache.tick_value;
double tick_size = symCache.tick_size;
double point = symCache.point;
if(IsEqual(tick_value, 0) || IsEqual(point, 0))
{
Log(LOG_LEVEL_ERROR, "ERRO Lote: Tick Value ou Point inválido (0)");
perfMonitor.Stop();
return 0.0;
}

// Custo de 1 ponto de movimento para 1 lote padrão
double cost_per_point = tick_value / tick_size;
// Custo do Stop Loss em pontos para 1 lote padrão (considerando o ponto do símbolo)
cost_per_lot = sl_points * cost_per_point;
if(IsLessOrEqual(cost_per_lot, 0))
{
Log(LOG_LEVEL_ERROR, "ERRO Lote: Custo por lote inválido (0). Verifique SymbolInfo.");
perfMonitor.Stop();
return 0.0;
}

// 3. Calcular o volume necessário
double lot = risk_amount / cost_per_lot;
// 4. Normalizar e aplicar limites de volume
double lot_step = symCache.volume_step;
double min_lot = symCache.min_volume;
double max_lot = symCache.max_volume;

double normalized_lot = MathRound(lot / lot_step) * lot_step;
if(normalized_lot < min_lot)
normalized_lot = min_lot;
if(normalized_lot > max_lot)
normalized_lot = max_lot;
Log(LOG_LEVEL_INFO, "LOTE CALCULADO: Risco Monetário=" + (string)risk_amount + ", Custo/Lote=" + (string)cost_per_lot + ", Lote Original=" + (string)lot + ", Lote Final=" + (string)normalized_lot);
perfMonitor.Stop();
return normalized_lot;
}

//+------------------------------------------------------------------+
//| (OTIMIZADO) Calcular Distância Adaptativa do SL em Pontos |
//+------------------------------------------------------------------+
double CalculateAdaptiveStopLossPoints(ENUM_ORDER_TYPE orderType)
{
perfMonitor.Start("CalculateAdaptiveStopLossPoints");

if(!indicatorCache->IsValid())
{
Log(LOG_LEVEL_WARNING, "Cache de indicadores inválido. Usando FixedStopLoss.");
perfMonitor.Stop();
return FixedStopLoss;
}

double atr_value = indicatorCache->GetATRValue(1);
if(IsLessOrEqual(atr_value, 0))
{
Log(LOG_LEVEL_ERROR, "ERRO SL Adaptativo: Valor do ATR inválido.");
perfMonitor.Stop();
return FixedStopLoss;
}

double current_price = (orderType == ORDER_TYPE_BUY) ?
symCache.ask : symCache.bid;

if(IsLessOrEqual(current_price, 0))
{
Log(LOG_LEVEL_ERROR, "ERRO SL Adaptativo: Preço atual inválido.");
perfMonitor.Stop();
return FixedStopLoss;
}

// Análise de volatilidade
double atr_percentage = (atr_value / current_price) * 100;
double base_atr_multiplier = ATR_Multiplier_SL;

if(IsGreater(atr_percentage, 2.0))
base_atr_multiplier *= 2.0;
else if(IsGreater(atr_percentage, 1.0))
base_atr_multiplier *= 1.5;
else if(IsLess(atr_percentage, 0.1))
base_atr_multiplier *= 0.7;

double sl_distance_price = atr_value * base_atr_multiplier;
double sl_distance_points = sl_distance_price / symCache.point;

Log(LOG_LEVEL_DEBUG, "SL Adaptativo: ATR=" + (string)atr_value + " (" + DoubleToString(atr_percentage, 2) + "%), Multiplicador=" + (string)base_atr_multiplier + ", Distância=" + (string)sl_distance_price + " (" + (string)sl_distance_points + " pts)");
perfMonitor.Stop();
return sl_distance_points;
}

//+------------------------------------------------------------------+
//| (OTIMIZADO) Proteção de Capital (Drawdown e Profit Watchdog) |
//+------------------------------------------------------------------+
void ManageCapitalWatchdog()
{
perfMonitor.Start("ManageCapitalWatchdog");

// 1. Proteção contra Drawdown (Diário e Total)
double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
MqlDateTime now;
TimeToStruct(TimeCurrent(), now);

// Reset diário do High Water Mark (se um novo dia começou)
MqlDateTime today;
TimeToStruct(TimeCurrent(), today);
today.hour = 0; today.min = 0; today.sec = 0;
datetime today_start = StructToTime(today);
if(G_DailyResetTime < today_start)
{
G_DailyResetTime = today_start;
G_DailyHighBalance = current_equity;
Log(LOG_LEVEL_INFO, "RESET DIÁRIO: Novo dia iniciado. High balance resetado para: " + (string)G_DailyHighBalance);
}

// Atualiza o High Water Mark Diário
if(IsGreater(current_equity, G_DailyHighBalance))
{
G_DailyHighBalance = current_equity;
}

double daily_drawdown_percent = 0;
double total_drawdown_percent = 0;
if(IsGreater(G_DailyHighBalance, 0))
{
daily_drawdown_percent = ((G_DailyHighBalance - current_equity) / G_DailyHighBalance) * 100;
}

if(IsGreater(G_InitialBalance, 0))
{
total_drawdown_percent = ((G_InitialBalance - current_equity) / G_InitialBalance) * 100;
}

if(IsGreaterOrEqual(daily_drawdown_percent, MaxDailyDrawdownPercent))
{
Log(LOG_LEVEL_ERROR, ">>> 🚨 PROTEÇÃO DRAWDOWN ATIVADA: DD Diário (" + DoubleToString(daily_drawdown_percent, 2) + "%) excedeu o limite (" + (string)MaxDailyDrawdownPercent + "%). Fechando todas as posições.");
CloseAllPositions();
}

if(IsGreaterOrEqual(total_drawdown_percent, MaxTotalDrawdownPercent))
{
Log(LOG_LEVEL_ERROR, ">>> 🚨 PROTEÇÃO DRAWDOWN TOTAL ATIVADA: DD Total (" + DoubleToString(total_drawdown_percent, 2) + "%) excedeu o limite (" + (string)MaxTotalDrawdownPercent + "%). Fechando todas as posições.");
CloseAllPositions();
}

// 2. Vigilante de Lucro (Profit Watchdog)
double ea_floating_profit = 0;
for(int i = 0; i < PositionsTotal(); i++)
{
ulong ticket = PositionGetTicket(i);
if(IsEAPosition(ticket))
{
ea_floating_profit += PositionGetDouble(POSITION_PROFIT);
}
}

if(Watchdog_Mode == MODE_WATCHDOG_STATIC_TARGET)
{
double profit_target_amount = G_InitialBalance * (Watchdog_ProfitPercent_Target / 100.0);
if(IsGreaterOrEqual(ea_floating_profit, profit_target_amount))
{
Log(LOG_LEVEL_INFO, ">>> 💰 VIGILANTE DE CAPITAL (ESTÁTICO) ATIVADO: Lucro (" + (string)ea_floating_profit + ") atingiu o alvo (" + (string)profit_target_amount + "). Fechando todas as posições.");
CloseAllPositions();
}
}
else if(Watchdog_Mode == MODE_WATCHDOG_DYNAMIC_TRAIL)
{
if(G_Watchdog_Trail_Active)
{
if(ea_floating_profit <= 0)
{
Log(LOG_LEVEL_INFO, "...Vigilante Dinâmico: Resetado (lucro zerou)");
G_Watchdog_Trail_Active = false;
G_Watchdog_HighWaterMark = 0.0;
}
else
{
// Calcula o valor de trailing em termos de lucro
double trail_amount = G_Watchdog_HighWaterMark * (Watchdog_Trail_Percent / 100.0);
double trail_level = G_Watchdog_HighWaterMark - trail_amount;

if(IsLessOrEqual(ea_floating_profit, trail_level))
{
Log(LOG_LEVEL_INFO, ">>> 💰 VIGILANTE DE CAPITAL (DINÂMICO) ATIVADO: Lucro em flutuação (" + (string)ea_floating_profit + ") violou o nível de trailing (" + (string)trail_level + "). Fechando todas as posições.");
CloseAllPositions();
}

// Atualiza o High Water Mark do lucro flutuante
if(IsGreater(ea_floating_profit, G_Watchdog_HighWaterMark))
{
G_Watchdog_HighWaterMark = ea_floating_profit;
Log(LOG_LEVEL_DEBUG, "Vigilante Dinâmico: Novo High Water Mark: " + (string)G_Watchdog_HighWaterMark);
}
}
}
else if(IsGreater(ea_floating_profit, 0))
{
// Ativar somente acima de um percentual fixo
if(IsGreaterOrEqual(ea_floating_profit, G_InitialBalance * (Watchdog_ProfitPercent_Target / 100.0) / 2))
{
G_Watchdog_Trail_Active = true;
G_Watchdog_HighWaterMark = ea_floating_profit;
Log(LOG_LEVEL_INFO, "Vigilante Dinâmico: ATIVADO. High Water Mark inicial: " + (string)G_Watchdog_HighWaterMark);
}
}
}

// 3. Max Loss Check
if(Watchdog_Use_MaxLoss)
{
double max_loss_amount = G_InitialBalance * (Watchdog_MaxLoss_Percent / 100.0);
if(IsLess(ea_floating_profit, -max_loss_amount))
{
Log(LOG_LEVEL_ERROR, ">>> 🚨 PROTEÇÃO MAX LOSS ATIVADA: Prejuízo em flutuação (" + (string)ea_floating_profit + ") excedeu o limite (" + (string)max_loss_amount + "). Fechando todas as posições.");
CloseAllPositions();
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//|
//|
//| Funções de Gerenciamento de Posições (Otimizadas) |
//+------------------------------------------------------------------+
bool IsEAPosition(ulong ticket)
{
if(PositionSelectByTicket(ticket))
{
if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == G_MagicNumber)
{
return true;
}
}
return false;
}

int GetEAPositionsTotal()
{
int count = 0;
for(int i = 0; i < PositionsTotal(); i++)
{
ulong ticket = PositionGetTicket(i);
if(IsEAPosition(ticket))
{
count++;
}
}
return count;
}

void ClosePosition(ulong ticket, double volume, ENUM_DEAL_TYPE deal_type)
{
perfMonitor.Start("ClosePosition");
MqlTradeRequest request;
MqlTradeResult result;
if(!PositionSelectByTicket(ticket))
{
Log(LOG_LEVEL_ERROR, "ClosePosition: Falha ao selecionar ticket " + (string)ticket);
perfMonitor.Stop();
return;
}

request.action = TRADE_ACTION_DEAL;
request.position = ticket;
request.symbol = PositionGetString(POSITION_SYMBOL);
request.volume = volume;
request.magic = G_MagicNumber;

ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

if (type == POSITION_TYPE_BUY)
{
request.type = ORDER_TYPE_SELL;
request.price = symCache.bid;
}
else if (type == POSITION_TYPE_SELL)
{
request.type = ORDER_TYPE_BUY;
request.price = symCache.ask;
}
else
{
Log(LOG_LEVEL_ERROR, "ClosePosition: Tipo de posição desconhecido para ticket " + (string)ticket);
perfMonitor.Stop();
return;
}

request.deviation = (uint)(Execution_SimulatedSlippagePoints / symCache.point);

bool sendResult = OrderSend(request, result);
if(sendResult)
{
if(recoveryManager->ProcessOrderResult(request, result, "FECHAMENTO TICKET " + (string)ticket))
{
// Clean up the initial stop loss arrays
for(int i = 0; i < ArraySize(G_InitialStopLoss_Tickets); i++)
{
if(G_InitialStopLoss_Tickets[i] == ticket)
{
ArrayRemove(G_InitialStopLoss, i, 1);
ArrayRemove(G_InitialStopLoss_Tickets, i, 1);
break;
}
}
}
}
else
{
Log(LOG_LEVEL_ERROR, "FECHAMENTO FALHOU: OrderSend error " + (string)GetLastError());
}

perfMonitor.Stop();
}

void CloseAllPositions()
{
perfMonitor.Start("CloseAllPositions");
int total_closed = 0;
for(int i = PositionsTotal() - 1; i >= 0; i--)
{
ulong ticket = PositionGetTicket(i);
if(IsEAPosition(ticket))
{
double volume = PositionGetDouble(POSITION_VOLUME);
ClosePosition(ticket, volume, (ENUM_DEAL_TYPE)PositionGetInteger(POSITION_TYPE));
total_closed++;
}
}

if(total_closed > 0)
{
Log(LOG_LEVEL_INFO, "FECHAMENTO GERAL: " + (string)total_closed + " posições fechadas.");
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//|
//|
//| Funções de Filtro de Mercado e Entrada (Otimizadas) |
//+------------------------------------------------------------------+
bool IsTradingHour()
{
perfMonitor.Start("IsTradingHour");

if(Is24_7_Market)
{
perfMonitor.Stop();
return true;
}

if(!UseTradingSessionFilter)
{
perfMonitor.Stop();
return true;
}

string current_time_str = TimeToString(TimeCurrent(), TIME_MINUTES);
int current_hhmm = StringToInteger(StringSubstr(current_time_str, 0, 2)) * 100 + StringToInteger(StringSubstr(current_time_str, 3, 2));

datetime start_time = StringToTime(TradingSession_Start);
datetime end_time = StringToTime(TradingSession_End);
MqlDateTime start_struct, end_struct;
TimeToStruct(start_time, start_struct);
TimeToStruct(end_time, end_struct);

int start_hhmm = start_struct.hour * 100 + start_struct.min;
int end_hhmm = end_struct.hour * 100 + end_struct.min;

bool is_in_session = false;
if (start_hhmm <= end_hhmm)
{
if (current_hhmm >= start_hhmm && current_hhmm <= end_hhmm)
{
is_in_session = true;
}
}
else
{
if (current_hhmm >= start_hhmm || current_hhmm <= end_hhmm)
{
is_in_session = true;
}
}

if (!is_in_session)
{
Log(LOG_LEVEL_INFO, "FILTRO DE SESSÃO: Fora do horário de negociação. Atual: " + current_time_str);
}

perfMonitor.Stop();
return is_in_session;
}

bool CheckMarketFilters()
{
perfMonitor.Start("CheckMarketFilters");
// 1. Filtro de Sessão
if (!IsTradingHour())
{
perfMonitor.Stop();
return false;
}

// 2. Filtro de Spread
if(UseSpreadFilter)
{
double current_spread_points = symCache.spread / symCache.point;
if(IsGreater(current_spread_points, MaxSpreadPoints))
{
Log(LOG_LEVEL_INFO, "FILTRO DE SPREAD: Spread (" + (string)current_spread_points + " pts) > Máximo (" + (string)MaxSpreadPoints + " pts)");
perfMonitor.Stop();
return false;
}
}

// 3. Filtro ATR (Volatilidade Mínima)
if(UseATR_Filter)
{
if(!indicatorCache->IsValid())
{
Log(LOG_LEVEL_WARNING, "FILTRO ATR: Cache inválido. Ignorando filtro ATR.");
}
else
{
double atr_value = indicatorCache->GetATRValue(1);
double atr_value_points = atr_value / symCache.point;
if(IsLess(atr_value_points, MinATR_Value_Points))
{
Log(LOG_LEVEL_INFO, "FILTRO ATR: Volatilidade (" + (string)atr_value_points + " pts) < Mínima (" + (string)MinATR_Value_Points + " pts)");
perfMonitor.Stop();
return false;
}
}
}

perfMonitor.Stop();
return true;
}

bool CheckEntryFilters(ENUM_ORDER_TYPE signal)
{
perfMonitor.Start("CheckEntryFilters");

if(signal == ORDER_TYPE_BUY || signal == ORDER_TYPE_SELL)
{
// 1. Filtro de Tempo (diário)
if(UseTimeFilter)
{
MqlDateTime now;
TimeToStruct(TimeCurrent(), now);
int current_hhmm = now.hour * 100 + now.min;
if(G_Start_HHMM <= G_End_HHMM)
{
if(current_hhmm < G_Start_HHMM || current_hhmm > G_End_HHMM)
{
Log(LOG_LEVEL_INFO, "FILTRO DE TEMPO: Fora do horário de negociação diária.");
perfMonitor.Stop();
return false;
}
}
else
{
if(current_hhmm < G_Start_HHMM && current_hhmm > G_End_HHMM)
{
// CORRIGIDO: String quebrada em duas linhas
Log(LOG_LEVEL_INFO, "FILTRO DE TEMPO: Fora do horário de negociação diária (crossover).");
perfMonitor.Stop();
return false;
}
}
}

// 2. Filtro Multi-Timeframe (MTF)
if(MtfFilterMode != MTF_FILTER_DISABLED)
{
if(htf_ichimoku_handle == INVALID_HANDLE)
{
Log(LOG_LEVEL_ERROR, "FILTRO MTF: Handle do Ichimoku MTF inválido.");
perfMonitor.Stop();
return true;
}

// Variáveis temporárias para o MTF
double mtf_tenkan[2], mtf_kijun[2], mtf_senkouA[2], mtf_senkouB[2];
int copy_count = 2;

// Tenta obter dados do timeframe superior
if(CopyBuffer(htf_ichimoku_handle, 0, 0, copy_count, mtf_tenkan) != copy_count ||
CopyBuffer(htf_ichimoku_handle, 1, 0, copy_count, mtf_kijun) != copy_count ||
CopyBuffer(htf_ichimoku_handle, 2, 0, copy_count, mtf_senkouA) != copy_count ||
CopyBuffer(htf_ichimoku_handle, 3, 0, copy_count, mtf_senkouB) != copy_count)
{
Log(LOG_LEVEL_WARNING, "FILTRO MTF: Dados indisponíveis no " + EnumToString(HigherTimeframe) + ". Ignorando filtro.");
perfMonitor.Stop();
return true;
}

bool is_mtf_bullish = false;
bool is_mtf_bearish = false;

if(MtfFilterMode == MTF_FILTER_ICHIMOKU_CLOUD)
{
// Cloud (Senkou Span A > Senkou Span B)
is_mtf_bullish = IsGreater(mtf_senkouA[1], mtf_senkouB[1]);
is_mtf_bearish = IsLess(mtf_senkouA[1], mtf_senkouB[1]);
}
else if(MtfFilterMode == MTF_FILTER_ICHIMOKU_KIJUN)
{
// Kijun-sen (Preço > Kijun)
double htf_current_price = iClose(_Symbol, HigherTimeframe, 0);
is_mtf_bullish = IsGreater(htf_current_price, mtf_kijun[1]);
is_mtf_bearish = IsLess(htf_current_price, mtf_kijun[1]);
}

if (signal == ORDER_TYPE_BUY && !is_mtf_bullish)
{
Log(LOG_LEVEL_INFO, "FILTRO MTF: Sinal de Compra BLOQUEADO. MTF não é de alta.");
perfMonitor.Stop();
return false;
}

if (signal == ORDER_TYPE_SELL && !is_mtf_bearish)
{
Log(LOG_LEVEL_INFO, "FILTRO MTF: Sinal de Venda BLOQUEADO. MTF não é de baixa.");
perfMonitor.Stop();
return false;
}

Log(LOG_LEVEL_DEBUG, "FILTRO MTF: Sinal " + EnumToString(signal) + " PERMITIDO pela análise MTF.");
}
}

perfMonitor.Stop();
return true;
}

//+------------------------------------------------------------------+
//|
//|
//| Funções de Sinal (Otimizadas) |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE GetIchimokuSignal()
{
perfMonitor.Start("GetIchimokuSignal");
if(!indicatorCache->IsValid())
{
Log(LOG_LEVEL_ERROR, "SINAL ICHIMOKU: Cache inválido.");
perfMonitor.Stop();
return WRONG_VALUE;
}

double tenkan_current = indicatorCache->GetTenkanValue(0);
double kijun_current = indicatorCache->GetKijunValue(0);
double tenkan_prev = indicatorCache->GetTenkanValue(1);
double kijun_prev = indicatorCache->GetKijunValue(1);
double price_current = iClose(_Symbol, _Period, 0);

ENUM_ORDER_TYPE signal = WRONG_VALUE;
// Critério 1: Cruzamento Tenkan/Kijun (Sinal Principal)
if (IsGreater(tenkan_current, kijun_current) && IsLess(tenkan_prev, kijun_prev))
{
signal = ORDER_TYPE_BUY;
Log(LOG_LEVEL_DEBUG, "ICHIMOKU: Cruzamento T/K de alta.");
}
else if (IsLess(tenkan_current, kijun_current) && IsGreater(tenkan_prev, kijun_prev))
{
signal = ORDER_TYPE_SELL;
Log(LOG_LEVEL_DEBUG, "ICHIMOKU: Cruzamento T/K de baixa.");
}

// Critério 2: Filtragem pela Nuvem
double senkouA_current = 0, senkouB_current = 0;
double senkouA_buffer[], senkouB_buffer[];
ArraySetAsSeries(senkouA_buffer, true);
ArraySetAsSeries(senkouB_buffer, true);

// A nuvem Ichimoku é deslocada para a frente. Para obter o valor da nuvem para a barra atual,
// precisamos buscar os dados do indicador com um deslocamento igual ao KijunPeriod.
if(CopyBuffer(ichimoku_handle, 2, KijunPeriod, 1, senkouA_buffer) == 1 &&
   CopyBuffer(ichimoku_handle, 3, KijunPeriod, 1, senkouB_buffer) == 1)
{
senkouA_current = senkouA_buffer[0];
senkouB_current = senkouB_buffer[0];

if (signal == ORDER_TYPE_BUY)
{
double upper_cloud = MathMax(senkouA_current, senkouB_current);
if (IsLess(price_current, upper_cloud))
{
Log(LOG_LEVEL_DEBUG, "ICHIMOKU: Compra rejeitada - Preço está abaixo da Nuvem.");
signal = WRONG_VALUE;
}
}
else if (signal == ORDER_TYPE_SELL)
{
double lower_cloud = MathMin(senkouA_current, senkouB_current);
if (IsGreater(price_current, lower_cloud))
{
Log(LOG_LEVEL_DEBUG, "ICHIMOKU: Venda rejeitada - Preço está acima da Nuvem.");
signal = WRONG_VALUE;
}
}
}

perfMonitor.Stop();
return signal;
}

ENUM_ORDER_TYPE GetRSISignal()
{
perfMonitor.Start("GetRSISignal");
if(!indicatorCache->IsValid())
{
Log(LOG_LEVEL_ERROR, "SINAL RSI: Cache inválido.");
perfMonitor.Stop();
return WRONG_VALUE;
}

double rsi_current = indicatorCache->GetRSIValue(0);
double rsi_prev = indicatorCache->GetRSIValue(1);
ENUM_ORDER_TYPE signal = WRONG_VALUE;

// Critério 1: Cruzamento do nível de Exaustão (Compra)
if (IsLess(rsi_prev, RSIOversold) && IsGreaterOrEqual(rsi_current, RSIOversold))
{
signal = ORDER_TYPE_BUY;
Log(LOG_LEVEL_DEBUG, "RSI: Cruzamento de Oversold (" + (string)RSIOversold + ") de alta.");
}
// Critério 2: Cruzamento do nível de Exaustão (Venda)
else if (IsGreater(rsi_prev, RSIOverbought) && IsLessOrEqual(rsi_current, RSIOverbought))
{
signal = ORDER_TYPE_SELL;
Log(LOG_LEVEL_DEBUG, "RSI: Cruzamento de Overbought (" + (string)RSIOverbought + ") de baixa.");
}

perfMonitor.Stop();
return signal;
}

ENUM_ORDER_TYPE GetTradingSignal()
{
perfMonitor.Start("GetTradingSignal");
ENUM_ORDER_TYPE rsi_signal = WRONG_VALUE;
ENUM_ORDER_TYPE ichimoku_signal = WRONG_VALUE;
ENUM_ORDER_TYPE final_signal = WRONG_VALUE;
// Obter sinais brutos
if (IndicatorMode == INDICATOR_RSI_ONLY || IndicatorMode == INDICATOR_RSI_W_ICHIMOKU_FILTER || IndicatorMode == INDICATOR_BOTH_STRONG)
{
rsi_signal = GetRSISignal();
}

if (IndicatorMode == INDICATOR_ICHIMOKU_ONLY || IndicatorMode == INDICATOR_RSI_W_ICHIMOKU_FILTER || IndicatorMode == INDICATOR_BOTH_STRONG)
{
ichimoku_signal = GetIchimokuSignal();
}

// Combinação de sinais
switch(IndicatorMode)
{
case INDICATOR_RSI_ONLY:
final_signal = rsi_signal;
break;

case INDICATOR_ICHIMOKU_ONLY:
final_signal = ichimoku_signal;
break;
case INDICATOR_BOTH_STRONG:
if (rsi_signal == ichimoku_signal && rsi_signal != WRONG_VALUE)
{
final_signal = rsi_signal;
Log(LOG_LEVEL_INFO, "SINAL: Forte Confirmação de " + EnumToString(final_signal));
}
break;
case INDICATOR_RSI_W_ICHIMOKU_FILTER:
if (rsi_signal != WRONG_VALUE && rsi_signal == ichimoku_signal)
{
final_signal = rsi_signal;
}
else if (rsi_signal != WRONG_VALUE && ichimoku_signal != WRONG_VALUE)
{
Log(LOG_LEVEL_INFO, "SINAL: Conflito RSI/Ichimoku. Não negociar.");
final_signal = WRONG_VALUE;
}
else
{
final_signal = WRONG_VALUE;
}
break;
}

// Inversão de Sinal
if(final_signal != WRONG_VALUE && InvertTradeSignal)
{
if(final_signal == ORDER_TYPE_BUY)
{
final_signal = ORDER_TYPE_SELL;
Log(LOG_LEVEL_WARNING, "INVERSÃO: Sinal de Compra invertido para Venda.");
}
else if(final_signal == ORDER_TYPE_SELL)
{
final_signal = ORDER_TYPE_BUY;
Log(LOG_LEVEL_WARNING, "INVERSÃO: Sinal de Venda invertido para Compra.");
}
}

perfMonitor.Stop();
return final_signal;
}

//+------------------------------------------------------------------+
//|
//| Função de Envio de Ordem (OpenTrade) |
//+------------------------------------------------------------------+
bool OpenTrade(ENUM_ORDER_TYPE type)
{
perfMonitor.Start("OpenTrade");
MqlTradeRequest request;
MqlTradeResult result;
// 1. Calcular SL/TP em pontos
double sl_points = UseDynamicStopLoss ? CalculateAdaptiveStopLossPoints(type) : FixedStopLoss;
double tp_points = RiskRewardRatio * sl_points;

// 2. Calcular Lote
double volume = CalculateLotSize(sl_points, type);
if(IsLessOrEqual(volume, 0))
{
Log(LOG_LEVEL_ERROR, "OpenTrade: Volume de lote inválido. Abortando.");
perfMonitor.Stop();
return false;
}

// 3. Montar Request
request.action = TRADE_ACTION_DEAL;
request.symbol = _Symbol;
request.volume = volume;
request.magic = G_MagicNumber;
request.type = type;
request.deviation = (uint)(Execution_SimulatedSlippagePoints / symCache.point);
request.type_filling = ORDER_FILLING_FOK;
// 4. Calcular Preços de Entrada, SL e TP
double entry_price = (type == ORDER_TYPE_BUY) ?
symCache.ask : symCache.bid;
request.price = entry_price;

if (sl_points > 0)
{
if (type == ORDER_TYPE_BUY)
{
request.sl = NormalizeDouble(entry_price - (sl_points * symCache.point), _Digits);
}
else
{
request.sl = NormalizeDouble(entry_price + (sl_points * symCache.point), _Digits);
}
}

// TP é calculado apenas se Dynamic Take Profit estiver DISABLED
if (DynamicTakeProfitMode == DYNAMIC_TP_DISABLED)
{
if (tp_points > 0)
{
if (type == ORDER_TYPE_BUY)
{
request.tp = NormalizeDouble(entry_price + (tp_points * symCache.point), _Digits);
}
else
{
request.tp = NormalizeDouble(entry_price - (tp_points * symCache.point), _Digits);
}
}
}

// 5. Enviar Ordem com Recovery
Log(LOG_LEVEL_INFO, "OpenTrade: Tentativa de " + EnumToString(type) + " " + DoubleToString(volume, 2) + " Lote, SL: " + (string)request.sl + ", TP: " + (string)request.tp);
bool sendResult = OrderSend(request, result);
if(sendResult)
{
bool success = recoveryManager->ProcessOrderResult(request, result, "ABERTURA");
if(success)
{
last_trade_bar = (int)iBarShift(_Symbol, _Period, TimeCurrent(), true);
// Store the initial stop loss
int size = ArraySize(G_InitialStopLoss);
ArrayResize(G_InitialStopLoss, size + 1);
ArrayResize(G_InitialStopLoss_Tickets, size + 1);
G_InitialStopLoss[size] = request.sl;
G_InitialStopLoss_Tickets[size] = result.order;
}
perfMonitor.Stop();
return success;
}

Log(LOG_LEVEL_ERROR, "OrderSend falhou: " + (string)GetLastError());
perfMonitor.Stop();
return false;
}

//+------------------------------------------------------------------+
//|
//|
//| (OTIMIZADO) Função Principal de Gerenciamento de Posições |
//+------------------------------------------------------------------+
void ManageTrades()
{
perfMonitor.Start("ManageTrades");

for(int i = PositionsTotal() - 1; i >= 0; i--)
{
ulong ticket = PositionGetTicket(i);
if(IsEAPosition(ticket))
{
if(!PositionSelectByTicket(ticket)) continue;
// 1. Gerenciar Parâmetros Estáticos (SL/TP inicial)
ManageStopLossAndTakeProfit(ticket);
// 2. Gerenciar BreakEven
ManageBreakEven(ticket);
// 3. Gerenciar Saídas Dinâmicas/Monitoramento Ativo
ManageActiveTrailingStop(ticket);
ManageDynamicTakeProfit(ticket);
// 4. Gerenciar Trailing Stop Estático (se não houver TS ativo)
if (ActiveTrailStopMode == ACTIVE_TS_DISABLED)
{
ManageTrailingStop(ticket);
}

// 5. Gerenciar Fechamento Parcial
ManagePartialClose(ticket);
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//|
//|
//| Gerenciamento SL/TP (Inicial/Garantia) |
//+------------------------------------------------------------------+
void ManageStopLossAndTakeProfit(ulong ticket)
{
if(!PositionSelectByTicket(ticket)) return;

double sl_price = PositionGetDouble(POSITION_SL);
double tp_price = PositionGetDouble(POSITION_TP);
// Se o TP dinâmico estiver ativo, não tentar reajustar o TP estático aqui.
if(DynamicTakeProfitMode != DYNAMIC_TP_DISABLED) return;
if(IsEqual(tp_price, 0.0))
{
// Se o TP estiver faltando (pode acontecer após recovery), recalcula e tenta modificar
Log(LOG_LEVEL_DEBUG, "SL/TP: TP faltando. Recalculando...");
double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
long type = PositionGetInteger(POSITION_TYPE);

// Recalcular SL/TP em pontos usando a mesma lógica de OpenTrade
double sl_points = UseDynamicStopLoss ?
CalculateAdaptiveStopLossPoints((ENUM_ORDER_TYPE)type) : FixedStopLoss;
double tp_points = RiskRewardRatio * sl_points;

double new_tp = 0.0;
if (tp_points > 0)
{
if (type == POSITION_TYPE_BUY)
{
new_tp = NormalizeDouble(entry_price + (tp_points * symCache.point), _Digits);
}
else
{
new_tp = NormalizeDouble(entry_price - (tp_points * symCache.point), _Digits);
}
}

if (new_tp > 0)
{
recoveryManager->ModifyStopLossWithRecovery(ticket, sl_price, new_tp);
}
}
}

//+------------------------------------------------------------------+
//| Trailing Stop Estático |
//+------------------------------------------------------------------+
void ManageTrailingStop(ulong ticket)
{
if(!UseTrailingStop || !PositionSelectByTicket(ticket)) return;

perfMonitor.Start("ManageTrailingStop");

long type = PositionGetInteger(POSITION_TYPE);
double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
double current_sl = PositionGetDouble(POSITION_SL);
double distance_points = MathAbs(current_price - entry_price) / symCache.point;
double trail_points_price = TrailingStopPoints * symCache.point;
double new_sl_price = 0.0;
if (type == POSITION_TYPE_BUY)
{
// Apenas se a posição estiver em lucro e o lucro > TrailingStopPoints
if (IsGreater(distance_points, TrailingStopPoints))
{
// Calcula o novo SL (Preço Atual - TrailingStopPoints)
new_sl_price = NormalizeDouble(current_price - trail_points_price, _Digits);
// Só ajusta se o novo SL for maior que o SL atual (movendo a favor do lucro)
if (IsGreater(new_sl_price, current_sl))
{
Log(LOG_LEVEL_INFO, "TS: Buy - Move SL de " + (string)current_sl + " para " + (string)new_sl_price);
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
}
else if (type == POSITION_TYPE_SELL)
{
// Apenas se a posição estiver em lucro e o lucro > TrailingStopPoints
if (IsGreater(distance_points, TrailingStopPoints))
{
// Calcula o novo SL (Preço Atual + TrailingStopPoints)
new_sl_price = NormalizeDouble(current_price + trail_points_price, _Digits);
// Só ajusta se o novo SL for menor que o SL atual (movendo a favor do lucro)
if (IsLess(new_sl_price, current_sl) || IsEqual(current_sl, 0.0))
{
Log(LOG_LEVEL_INFO, "TS: Sell - Move SL de " + (string)current_sl + " para " + (string)new_sl_price);
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//| Break Even (Ponto de Equilíbrio) |
//+------------------------------------------------------------------+
void ManageBreakEven(ulong ticket)
{
if(!UseBreakEven || !PositionSelectByTicket(ticket)) return;

perfMonitor.Start("ManageBreakEven");

long type = PositionGetInteger(POSITION_TYPE);
double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
double current_sl = PositionGetDouble(POSITION_SL);
double distance_points = MathAbs(current_price - entry_price) / symCache.point;
// O ponto de BreakEven é o preço de entrada + 1 ponto (para cobrir comissões/slippage)
double be_price_buffer = symCache.point;
double new_sl_price = 0.0;

// Check 1: Posição alcançou o lucro alvo do BreakEven?
if (IsGreaterOrEqual(distance_points, BreakEvenPoints))
{
// Check 2: O SL atual já está no BreakEven ou melhor?
if (type == POSITION_TYPE_BUY)
{
new_sl_price = NormalizeDouble(entry_price + be_price_buffer, _Digits);
if (IsLess(current_sl, new_sl_price))
{
Log(LOG_LEVEL_INFO, "BE: Buy - Move SL para BreakEven (" + (string)new_sl_price + ")");
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
else if (type == POSITION_TYPE_SELL)
{
new_sl_price = NormalizeDouble(entry_price - be_price_buffer, _Digits);
if (IsGreater(current_sl, new_sl_price) || IsEqual(current_sl, 0.0))
{
Log(LOG_LEVEL_INFO, "BE: Sell - Move SL para BreakEven (" + (string)new_sl_price + ")");
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//| Trailing Stop Ativo (Indicador) |
//+------------------------------------------------------------------+
void ManageActiveTrailingStop(ulong ticket)
{
if(ActiveTrailStopMode == ACTIVE_TS_DISABLED || !PositionSelectByTicket(ticket)) return;

perfMonitor.Start("ManageActiveTrailingStop");
if(!indicatorCache->IsValid())
{
Log(LOG_LEVEL_WARNING, "TS Ativo: Cache inválido. Ignorando.");
perfMonitor.Stop();
return;
}

long type = PositionGetInteger(POSITION_TYPE);
double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
double current_sl = PositionGetDouble(POSITION_SL);
double new_sl_price = 0.0;
double kijun_value = indicatorCache->GetKijunValue(1);
double tenkan_value = indicatorCache->GetTenkanValue(1);

if (ActiveTrailStopMode == ACTIVE_TS_KIJUN_SEN)
{
if (type == POSITION_TYPE_BUY)
{
new_sl_price = NormalizeDouble(kijun_value, _Digits);
// Novo SL deve ser maior que o SL atual E maior que o preço de entrada
if (IsGreater(new_sl_price, current_sl) && IsLess(new_sl_price, current_price))
{
Log(LOG_LEVEL_DEBUG, "TS Kijun: Buy - Movendo SL para Kijun: " + (string)new_sl_price);
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
else if (type == POSITION_TYPE_SELL)
{
new_sl_price = NormalizeDouble(kijun_value, _Digits);
// Novo SL deve ser menor que o SL atual E maior que o preço de entrada
if (IsLess(new_sl_price, current_sl) || IsEqual(current_sl, 0.0))
{
Log(LOG_LEVEL_DEBUG, "TS Kijun: Sell - Movendo SL para Kijun: " + (string)new_sl_price);
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
}
else if (ActiveTrailStopMode == ACTIVE_TS_TENKAN_SEN)
{
// Lógica similar usando Tenkan
if (type == POSITION_TYPE_BUY)
{
new_sl_price = NormalizeDouble(tenkan_value, _Digits);
if (IsGreater(new_sl_price, current_sl) && IsLess(new_sl_price, current_price))
{
Log(LOG_LEVEL_DEBUG, "TS Tenkan: Buy - Movendo SL para Tenkan: " + (string)new_sl_price);
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
else if (type == POSITION_TYPE_SELL)
{
new_sl_price = NormalizeDouble(tenkan_value, _Digits);
if (IsLess(new_sl_price, current_sl) || IsEqual(current_sl, 0.0))
{
Log(LOG_LEVEL_DEBUG, "TS Tenkan: Sell - Movendo SL para Tenkan: " + (string)new_sl_price);
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//| Take Profit Dinâmico (Saída no Sinal Oposto) |
//+------------------------------------------------------------------+
void ManageDynamicTakeProfit(ulong ticket)
{
if(DynamicTakeProfitMode == DYNAMIC_TP_DISABLED || !PositionSelectByTicket(ticket)) return;

perfMonitor.Start("ManageDynamicTakeProfit");
if(!indicatorCache->IsValid())
{
Log(LOG_LEVEL_WARNING, "TP Dinâmico: Cache inválido. Ignorando.");
perfMonitor.Stop();
return;
}

long type = PositionGetInteger(POSITION_TYPE);

ENUM_ORDER_TYPE opposite_signal = WRONG_VALUE;
if (DynamicTakeProfitMode == DYNAMIC_TP_RSI_OPPOSITE)
{
// Saída em RSI Overbought para Compra / Oversold para Venda
double rsi_current = indicatorCache->GetRSIValue(0);
if (type == POSITION_TYPE_BUY && IsGreaterOrEqual(rsi_current, RSIOverbought))
{
opposite_signal = ORDER_TYPE_SELL;
Log(LOG_LEVEL_INFO, "TP Dinâmico: Saída de Compra por RSI Overbought.");
}
else if (type == POSITION_TYPE_SELL && IsLessOrEqual(rsi_current, RSIOversold))
{
opposite_signal = ORDER_TYPE_BUY;
Log(LOG_LEVEL_INFO, "TP Dinâmico: Saída de Venda por RSI Oversold.");
}
}
else if (DynamicTakeProfitMode == DYNAMIC_TP_ICHIMOKU_CROSS)
{
// Saída em cruzamento Tenkan/Kijun oposto (requer lucro)
double tenkan_current = indicatorCache->GetTenkanValue(0);
double kijun_current = indicatorCache->GetKijunValue(0);
double tenkan_prev = indicatorCache->GetTenkanValue(1);
double kijun_prev = indicatorCache->GetKijunValue(1);
if (type == POSITION_TYPE_BUY)
{
if (IsLess(tenkan_current, kijun_current) && IsGreater(tenkan_prev, kijun_prev))
{
opposite_signal = ORDER_TYPE_SELL;
Log(LOG_LEVEL_INFO, "TP Dinâmico: Saída de Compra por Cruzamento T/K de baixa.");
}
}
else if (type == POSITION_TYPE_SELL)
{
if (IsGreater(tenkan_current, kijun_current) && IsLess(tenkan_prev, kijun_prev))
{
opposite_signal = ORDER_TYPE_BUY;
Log(LOG_LEVEL_INFO, "TP Dinâmico: Saída de Venda por Cruzamento T/K de alta.");
}
}
}

if (opposite_signal != WRONG_VALUE)
{
// Apenas fechar se estiver em lucro
if (PositionGetDouble(POSITION_PROFIT) >= 0)
{
double volume = PositionGetDouble(POSITION_VOLUME);
ClosePosition(ticket, volume, (ENUM_DEAL_TYPE)type);
}
else
{
Log(LOG_LEVEL_INFO, "TP Dinâmico: Sinal oposto detectado, mas posição está em prejuízo. Não fechar.");
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//|
//|
//| Fechamento Parcial Avançado |
//+------------------------------------------------------------------+
void ManagePartialClose(ulong ticket)
{
if(!UsePartialClose || !PositionSelectByTicket(ticket)) return;

perfMonitor.Start("ManagePartialClose");

// Check 1: A posição já teve fechamento parcial?
// (Usando um comentário no ticket)
string comment = PositionGetString(POSITION_COMMENT);
if(StringFind(comment, PartialCloseMarker) != -1)
{
perfMonitor.Stop();
return;
}

long type = PositionGetInteger(POSITION_TYPE);
double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
double current_price = PositionGetDouble(POSITION_PRICE_CURRENT);
double current_sl = PositionGetDouble(POSITION_SL);
double initial_volume = PositionGetDouble(POSITION_VOLUME);

// Requisito: Apenas se tiver lucro
if(PositionGetDouble(POSITION_PROFIT) <= 0)
{
perfMonitor.Stop();
return;
}

// 1. Calcular a distância em pontos alcançada
double distance_points = MathAbs(current_price - entry_price) / symCache.point;
// 2. Calcular o alvo RR para fechamento parcial
double initial_sl = 0;
for(int i = 0; i < ArraySize(G_InitialStopLoss_Tickets); i++)
{
if(G_InitialStopLoss_Tickets[i] == ticket)
{
initial_sl = G_InitialStopLoss[i];
break;
}
}
if(initial_sl == 0)
{
perfMonitor.Stop();
return;
}
double sl_points_original = MathAbs(entry_price - initial_sl) / symCache.point;
double rr_target_points = sl_points_original * PartialClose_RR_Target;

// 3. Verificar se o alvo foi atingido
if (IsGreaterOrEqual(distance_points, rr_target_points))
{
// 4. Calcular o volume a fechar
double close_volume = initial_volume * (PartialClose_Percent / 100.0);
double lot_step = symCache.volume_step;

// Normalizar volume de fechamento
close_volume = MathRound(close_volume / lot_step) * lot_step;
if (close_volume > initial_volume) close_volume = initial_volume;
if (close_volume < symCache.min_volume)
{
Log(LOG_LEVEL_WARNING, "FECHAMENTO PARCIAL: Volume a fechar muito pequeno. Abortando.");
perfMonitor.Stop();
return;
}

// 5. Fechar parcial
Log(LOG_LEVEL_INFO, "FECHAMENTO PARCIAL: Alvo RR " + (string)PartialClose_RR_Target + " atingido. Fechando " + DoubleToString(close_volume, 2) + " Lotes.");
ClosePosition(ticket, close_volume, (ENUM_DEAL_TYPE)type);

// 6. Mover SL para BreakEven ou melhor (se ativado)
if(PartialClose_MoveToBe)
{
// O SL deve estar a 1 ponto de lucro (BE + buffer)
double be_price_buffer = symCache.point;
double new_sl_price = 0.0;

if (type == POSITION_TYPE_BUY)
{
new_sl_price = NormalizeDouble(entry_price + be_price_buffer, _Digits);
}
else if (type == POSITION_TYPE_SELL)
{
new_sl_price = NormalizeDouble(entry_price - be_price_buffer, _Digits);
}

if (new_sl_price > 0)
{
Log(LOG_LEVEL_INFO, "FECHAMENTO PARCIAL: Movendo SL restante para BreakEven.");
recoveryManager->ModifyStopLossWithRecovery(ticket, new_sl_price);
}
}

// 7. Marcar a posição como Parcialmente Fechada
MqlTradeRequest request_comment;
MqlTradeResult result_comment;

request_comment.action = TRADE_ACTION_COMMENT;
request_comment.position = ticket;
request_comment.comment = comment + " " + PartialCloseMarker;
bool sendResult = OrderSend(request_comment, result_comment);
if(!sendResult)
{
Log(LOG_LEVEL_WARNING, "Não foi possível adicionar comentário à posição: " + (string)GetLastError());
}
}

perfMonitor.Stop();
}

//+------------------------------------------------------------------+
//|
//|
//| Função OnTick do Expert |
//+------------------------------------------------------------------+
void OnTick()
{
perfMonitor.Start("OnTick");

// 1. Atualizar Cache e HWM do Símbolo
UpdateSymbolCache();
ManageCapitalWatchdog();
// 2. Verificar se uma nova barra foi formada
datetime current_bar_time = iTime(_Symbol, _Period, 0);
bool new_bar = (current_bar_time != last_bar_time);

if(new_bar)
{
last_bar_time = current_bar_time;
// Atualizar cache de indicadores na nova barra
perfMonitor.Start("UpdateIndicatorCache");
indicatorCache->SetUpdated();
indicatorCache->UpdateRSIValues(rsi_handle);
indicatorCache->UpdateIchimokuValues(ichimoku_handle);
indicatorCache->UpdateATRValues(atr_handle);
perfMonitor.Stop();

Log(LOG_LEVEL_DEBUG, "NOVA BARRA: Cache de indicadores atualizado.");
}
else
{
// Se não for uma nova barra e não houver posições abertas, retorna para economizar CPU
if(GetEAPositionsTotal() == 0)
{
perfMonitor.Stop();
return;
}
}

// 3. Gerenciar posições existentes (sempre a cada tick)
ManageTrades();
// 4. Lógica de Entrada (apenas na nova barra E se os filtros de mercado permitirem)
if(new_bar && CheckMarketFilters())
{
int total_positions = GetEAPositionsTotal();
// 4.1. Filtrar limite máximo de ordens
if(total_positions < MaxOrders)
{
// 4.2.
// Filtrar distância entre trades (em barras)
int current_bar = (int)iBarShift(_Symbol, _Period, TimeCurrent(), true);
if(current_bar >= (last_trade_bar + MinBarsBetweenTrades))
{
// 4.3.
// Obter Sinal
ENUM_ORDER_TYPE signal = GetTradingSignal();
// 4.4. Filtrar Entrada
if (signal != WRONG_VALUE && CheckEntryFilters(signal))
{
// 4.5.
// Abrir Trade
OpenTrade(signal);
}
}
else
{
Log(LOG_LEVEL_DEBUG, "FILTRO DE BARRA: Aguardando " + (string)MinBarsBetweenTrades + " barras. Próxima em " + (string)(last_trade_bar + MinBarsBetweenTrades - current_bar) + " barras.");
}
}
else
{
Log(LOG_LEVEL_DEBUG, "LIMITE DE ORDENS: Máximo de posições (" + (string)MaxOrders + ") atingido.");
}
}

perfMonitor.Stop();
}
//+------------------------------------------------------------------+