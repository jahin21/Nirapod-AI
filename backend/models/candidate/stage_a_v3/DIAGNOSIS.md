# Stage A v3 tablet-volume and deeper-fine-tuning experiment

Status: offline candidate only; not promoted. Stage B, fusion, and APK unchanged.

## V2 confusion matrix

Rows are true classes and columns are predicted classes in this order:
`laptop`, `phone`, `tablet`, `screen_display`.

```text
[[39,  9,  2,  7],
 [ 2, 54, 10,  1],
 [ 6,  6, 27, 11],
 [16,  6, 11, 82]]
```

Tablet was not primarily confused with phone: among 23 tablet errors, six were
phone and eleven were screen display. Errors were spread across all classes.

## Tablet volume investigation

After v2 conflict cleanup, tablet counts were `200 train / 6 validation / 50
test`. Validation support was far below 30 and therefore unstable for early
stopping, per-class validation assessment, and calibration.

Official Open Images bounding-box metadata contained only 11 validation and 43
test tablet images total; nearly all were already present. Strict selection
found one additional clear tablet in each held-out split. Roboflow Universe
listed relevant CC BY 4.0 datasets, but its download endpoint was not a direct
no-auth export and examples required an API key, so it was not used.

V3 counts are `200 / 7 / 51`. This does not solve the validation-volume problem.

## Deeper fine-tuning

- ImageNet MobileNetV2, 224x224, batch 32
- Eight head epochs at `1e-3`
- Ten of up to sixteen fine-tuning epochs completed before early stopping
- Top 80 backbone layers considered; BatchNormalization frozen
- 53 of 154 backbone layers trainable
- Fine-tuning learning rate `3e-5`

## V3 result

- Clean train accuracy: 91.05%
- Validation accuracy: 77.69%
- Untouched test accuracy: 70.69%
- Tablet F1: 56.25% (27/51 correct)
- Validation ECE: 0.0640 before and 0.0284 after temperature scaling

V3 test confusion matrix:

```text
[[35, 12,  2,  8],
 [ 1, 56,  8,  2],
 [ 4,  9, 27, 11],
 [ 8, 12,  8, 87]]
```

## Recommendation

Do not merge tablet into phone yet. Only 9 of 24 tablet errors were phone,
while 11 were screen display and four were laptop. A `handheld_device` merge
would hide less than half of tablet errors and would remove useful product
semantics. The modest v2-to-v3 test gain (69.90% to 70.69%) alongside a much
higher train score indicates data quality/context and evaluation volume are now
more limiting than backbone capacity. Obtain a genuinely direct, licensed,
manually reviewed tablet dataset with at least 30-50 independent validation
images before another retrain or promotion decision.
