enum GrowthStage {
  dormant,    // 0 sessions
  cracking,   // 1–3
  seedling,   // 4–7
  growing,    // 8–14
  youngTree,  // 15–25
  blooming,   // 26–40
  forest,     // 41+
}

class GrowthStageHelper {
  static GrowthStage fromSessionCount(int count) {
    if (count == 0) return GrowthStage.dormant;
    if (count <= 3) return GrowthStage.cracking;
    if (count <= 7) return GrowthStage.seedling;
    if (count <= 14) return GrowthStage.growing;
    if (count <= 25) return GrowthStage.youngTree;
    if (count <= 40) return GrowthStage.blooming;
    return GrowthStage.forest;
  }

  static String description(GrowthStage stage) {
    switch (stage) {
      case GrowthStage.dormant:
        return 'bare soil. one dormant seed.';
      case GrowthStage.cracking:
        return 'the seed cracks. something stirs.';
      case GrowthStage.seedling:
        return 'a seedling. faint roots below.';
      case GrowthStage.growing:
        return 'small leaves. the soil is darker now.';
      case GrowthStage.youngTree:
        return 'roots run deep. sky begins to lighten.';
      case GrowthStage.blooming:
        return 'in bloom. birds have arrived.';
      case GrowthStage.forest:
        return 'ancient roots. primordial stillness.';
    }
  }
}
