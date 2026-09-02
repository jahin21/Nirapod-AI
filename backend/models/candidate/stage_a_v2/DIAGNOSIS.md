# Stage A v2 diagnosis and retraining result

Status: candidate only; not promoted or integrated. Stage B was not started.

## Why v1 training accuracy was low

- MobileNetV2 ImageNet weights were loaded, not random initialization. The
  cached 160px weight file was 9,406,464 bytes.
- V1 ran six epochs before early stopping, with Adam at `1e-3` and
  ReduceLROnPlateau. All 154 backbone layers were frozen.
- Batch size was 32 and input resolution was 160x160. This was the original
  trainer default, not a measured optimum.
- The reported 66% was the augmented-batch fit metric, not a clean post-fit
  train evaluation.
- More importantly, exact images carried contradictory single-class labels:
  70 train IDs, 31 validation IDs, and 43 test IDs appeared in multiple class
  folders. This is expected from multi-label scene annotations but invalid for
  a naive single-label folder classifier.

## V2 data correction

`monitor` and `tv_monitor` map to `screen_display`. Exact duplicates mapping to
that same target are collapsed. Images mapping to two different v2 targets are
excluded rather than assigned an arbitrary label.

- Train: 983 images; 21 same-target duplicates collapsed; 49 conflicts rejected
- Validation: 241 images; 12 collapsed; 19 conflicts rejected
- Test: 289 images; 18 collapsed; 25 conflicts rejected

The official Open Images train/validation/test boundaries remain unchanged.

## V2 training configuration

- Classes: laptop, phone, tablet, screen_display
- Backbone: MobileNetV2 with ImageNet weights
- Weight SHA-256: `f8aff69536bd77a692c594f559c798c19bf7f3f36668fc9fa00b21c6aab4797c`
- Input: 224x224 RGB; batch size 32
- Head phase: 8 epochs, Adam `1e-3`, backbone frozen
- Fine-tune phase: 8 epochs completed before early stopping, Adam `1e-5`
- Top 40 backbone layers considered; BatchNormalization stayed frozen, leaving
  26 trainable backbone layers out of 154
- Class weighting and training-only augmentation retained

## Results

- Clean training accuracy: 83.62%
- Validation accuracy: 76.76%
- Untouched test accuracy: 69.90%
- Test F1: laptop 65.00%, phone 76.06%, tablet 54.00%, screen_display 75.93%
- Validation ECE: 0.0256 before and 0.0290 after temperature scaling

Temperature scaling optimized validation negative log-likelihood but did not
improve ECE in this run. No calibration-improvement claim should be made. The
candidate remains unpromoted pending the user's decision and stricter object
presence review, especially for tablet.
