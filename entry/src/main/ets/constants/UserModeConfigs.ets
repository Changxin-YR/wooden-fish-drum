import { SessionMode, SoundType, ThemeMode, UserMode } from '../models/Enums';
import { UserModeConfig } from '../models/AppModels';

const PROGRAMMER_CONFIG: UserModeConfig = {
  mode: UserMode.PROGRAMMER,
  title: '程序员',
  description: '沉浸编码 · 代码无量 · 专注计数',
  detail: '专注计数 · 代码无量 · 效率统计',
  defaultText: 'Bug-1',
  availableTexts: ['Bug-1', '需求-1', '报错-1'],
  recommendedTargets: [10, 30, 60, 108],
  defaultTheme: ThemeMode.DARK,
  defaultSound: SoundType.CRISP,
  featureOrder: [SessionMode.FREE, SessionMode.TARGET, SessionMode.AUTO]
};

const MONK_CONFIG: UserModeConfig = {
  mode: UserMode.MONK,
  title: '僧侣',
  description: '诵经祈福 · 清净修善 · 修行辅助',
  detail: '修善功德 · 诵经计数 · 修行辅助',
  defaultText: '功德+1',
  availableTexts: ['功德+1', '善念+1', '烦恼-1'],
  recommendedTargets: [18, 36, 54, 108],
  defaultTheme: ThemeMode.LIGHT,
  defaultSound: SoundType.DEEP,
  featureOrder: [SessionMode.FREE, SessionMode.AUTO, SessionMode.TARGET]
};

const GENERAL_CONFIG: UserModeConfig = {
  mode: UserMode.GENERAL,
  title: '普通用户',
  description: '敲击解压 · 轻量体验 · 日常净心',
  detail: '减压净心 · 每日目标 · 轻松记录',
  defaultText: '功德+1',
  availableTexts: ['功德+1', '好运+1', '压力-1', '专注+1'],
  recommendedTargets: [10, 30, 60, 100],
  defaultTheme: ThemeMode.SYSTEM,
  defaultSound: SoundType.SOFT,
  featureOrder: [SessionMode.FREE, SessionMode.TARGET, SessionMode.AUTO]
};

export const USER_MODE_CONFIGS: Record<UserMode, UserModeConfig> = {
  [UserMode.PROGRAMMER]: PROGRAMMER_CONFIG,
  [UserMode.MONK]: MONK_CONFIG,
  [UserMode.GENERAL]: GENERAL_CONFIG
};

export const GENERAL_AVAILABLE_TEXTS: string[] = GENERAL_CONFIG.availableTexts;
