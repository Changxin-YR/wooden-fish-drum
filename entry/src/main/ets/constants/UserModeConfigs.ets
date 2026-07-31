import { SceneMode, SoundType, ThemeMode, ToolType, UserMode } from '../models/Enums';
import { SceneModeConfig, UserModeConfig } from '../models/AppModels';

export const SCENE_MODE_CONFIGS: Record<SceneMode, SceneModeConfig> = {
  [SceneMode.PROGRAMMER]: {
    mode: SceneMode.PROGRAMMER,
    title: '程序员模式',
    description: '工作间隙，找回专注节奏',
    defaultText: '专注+1',
    defaultTheme: ThemeMode.DARK,
    defaultSound: SoundType.CRISP,
    recommendedTool: ToolType.WOODEN_FISH
  },
  [SceneMode.MINDFUL]: {
    mode: SceneMode.MINDFUL,
    title: '静心模式',
    description: '安静计数，留一段清净时间',
    defaultText: '静心+1',
    defaultTheme: ThemeMode.LIGHT,
    defaultSound: SoundType.DEEP,
    recommendedTool: ToolType.INCENSE
  },
  [SceneMode.DAILY]: {
    mode: SceneMode.DAILY,
    title: '日常模式',
    description: '轻松使用，整理日常节律',
    defaultText: '放松+1',
    defaultTheme: ThemeMode.SYSTEM,
    defaultSound: SoundType.SOFT,
    recommendedTool: ToolType.WOODEN_FISH
  }
};

const PROGRAMMER_CONFIG: UserModeConfig = {
  mode: UserMode.PROGRAMMER,
  title: '程序员',
  description: '沉浸编码 · 代码无量 · 专注计数',
  detail: '专注计数 · 代码无量 · 效率统计',
  defaultText: 'Bug-1',
  availableTexts: ['Bug-1', '需求-1', '报错-1'],
  defaultTheme: ThemeMode.DARK,
  defaultSound: SoundType.CRISP
};

const MONK_CONFIG: UserModeConfig = {
  mode: UserMode.MONK,
  title: '僧侣',
  description: '诵经祈福 · 清净修善 · 修行辅助',
  detail: '修善功德 · 诵经计数 · 修行辅助',
  defaultText: '功德+1',
  availableTexts: ['功德+1', '善念+1', '烦恼-1'],
  defaultTheme: ThemeMode.LIGHT,
  defaultSound: SoundType.DEEP
};

const GENERAL_CONFIG: UserModeConfig = {
  mode: UserMode.GENERAL,
  title: '普通用户',
  description: '敲击解压 · 轻量体验 · 日常净心',
  detail: '减压净心 · 每日目标 · 轻松记录',
  defaultText: '功德+1',
  availableTexts: ['功德+1', '好运+1', '压力-1', '专注+1'],
  defaultTheme: ThemeMode.SYSTEM,
  defaultSound: SoundType.SOFT
};

export const USER_MODE_CONFIGS: Record<UserMode, UserModeConfig> = {
  [UserMode.PROGRAMMER]: PROGRAMMER_CONFIG,
  [UserMode.MONK]: MONK_CONFIG,
  [UserMode.GENERAL]: GENERAL_CONFIG
};

export const GENERAL_AVAILABLE_TEXTS: string[] = GENERAL_CONFIG.availableTexts;
