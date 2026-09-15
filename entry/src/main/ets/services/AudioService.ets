import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import audio from '@ohos.multimedia.audio';
import { SoundType } from '../models/Enums';
import { InitializationSlot } from './InitializationSlot';

class LoadedAudioResources {
  pool: media.SoundPool;
  soundIds: Map<SoundType, number>;

  constructor(pool: media.SoundPool, soundIds: Map<SoundType, number>) {
    this.pool = pool;
    this.soundIds = soundIds;
  }
}

export class AudioService {
  private resources: InitializationSlot<LoadedAudioResources> =
    new InitializationSlot<LoadedAudioResources>();

  async initialize(context: common.Context): Promise<void> {
    const generation: number = this.resources.begin();
    let candidatePool: media.SoundPool | null = null;
    try {
      const rendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
        rendererFlags: 0
      };
      candidatePool = await media.createSoundPool(8, rendererInfo);
      const candidateSoundIds: Map<SoundType, number> = new Map<SoundType, number>();

      const deepId: number | undefined = await this.load(context, candidatePool, 'sounds/deep.wav');
      if (!this.resources.isCurrent(generation)) {
        await this.releasePool(candidatePool);
        return;
      }
      if (deepId !== undefined) {
        candidateSoundIds.set(SoundType.DEEP, deepId);
      }

      const crispId: number | undefined = await this.load(context, candidatePool, 'sounds/crisp.wav');
      if (!this.resources.isCurrent(generation)) {
        await this.releasePool(candidatePool);
        return;
      }
      if (crispId !== undefined) {
        candidateSoundIds.set(SoundType.CRISP, crispId);
      }

      const softId: number | undefined = await this.load(context, candidatePool, 'sounds/soft.wav');
      if (!this.resources.isCurrent(generation)) {
        await this.releasePool(candidatePool);
        return;
      }
      if (softId !== undefined) {
        candidateSoundIds.set(SoundType.SOFT, softId);
      }

      const candidate: LoadedAudioResources = new LoadedAudioResources(candidatePool, candidateSoundIds);
      const discarded: LoadedAudioResources | null = this.resources.publish(generation, candidate);
      candidatePool = null;
      if (discarded !== null) {
        await this.releasePool(discarded.pool);
      }
    } catch {
      if (candidatePool !== null) {
        await this.releasePool(candidatePool);
      }
    }
  }

  async play(type: SoundType, volume: number): Promise<boolean> {
    const current: LoadedAudioResources | null = this.resources.current();
    if (current === null) {
      return false;
    }
    const soundId: number | undefined = current.soundIds.get(type);
    if (soundId === undefined) {
      return false;
    }
    try {
      await current.pool.play(soundId, {
        loop: 0,
        rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
        leftVolume: Math.max(0, Math.min(1, volume)),
        rightVolume: Math.max(0, Math.min(1, volume)),
        priority: 1
      });
      return true;
    } catch {
      return false;
    }
  }

  async release(): Promise<void> {
    const current: LoadedAudioResources | null = this.resources.cancel();
    if (current !== null) {
      await this.releasePool(current.pool);
    }
  }

  private async load(context: common.Context, pool: media.SoundPool,
    path: string): Promise<number | undefined> {
    let opened: boolean = false;
    try {
      const descriptor = await context.resourceManager.getRawFd(path);
      opened = true;
      return await pool.load(descriptor.fd, descriptor.offset, descriptor.length);
    } catch {
      return undefined;
    } finally {
      if (!opened) {
        return;
      }
      try {
        await context.resourceManager.closeRawFd(path);
      } catch {
      }
    }
  }

  private async releasePool(pool: media.SoundPool): Promise<void> {
    try {
      await pool.release();
    } catch {
    }
  }
}

export const audioService: AudioService = new AudioService();
