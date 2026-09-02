# Nirapod AI known-safe dataset tools

These tools prepare candidate data only for the **known-safe object classifier**.
They do not create or label hidden-camera positives, do not use personal API
keys, do not train during app/backend startup, and do not promote a model.

Supported classes:

- laptop
- phone
- tablet
- smart_speaker
- tv_monitor
- monitor

Open Images V7 does not define an exact `Smart speaker` class. Its broader
`Speaker` label may be collected only as a review candidate for the
`smart_speaker` folder. It must be manually relabelled or rejected before
training and must never be treated as an exact smart-speaker annotation.

## Non-negotiable data rules

- Use only Open Images official public metadata/downloads or a documented
  Roboflow Universe direct public export.
- Skip any dataset requiring authentication, an API key, or payment.
- Record the source URL and licence for every imported dataset.
- Human-review labels before training.
- Split by source object/scene before augmentation; augment training only.
- Unknown objects are not hidden cameras. They remain unclassified and require
  manual inspection.

## Open Images (recommended)

Download the official V7 class-description and human-verified image-label CSVs
from the Open Images download page. Generate lists for the official no-auth
downloader:

```powershell
python data_tools\open_images_known_safe.py `
  --class-descriptions metadata\oidv7-class-descriptions.csv `
  --annotations metadata\oidv7-train-annotations-human-imagelabels.csv `
  --split train --output candidate_data\open_images --max-per-class 500
```

The resulting text files contain `split/image_id` lines accepted by the
official Open Images downloader. Repeat independently for train, validation,
and test metadata; do not randomly split augmented copies.

After download, audit the fixed splits and render review samples:

```powershell
.\.venv-data\Scripts\python.exe data_tools\audit_known_safe.py `
  --root candidate_data\known_safe `
  --report candidate_data\known_safe\AUDIT.json `
  --contact-sheet candidate_data\known_safe\samples.jpg
```

Do not begin training unless the audit is leakage-free and a human has checked
that the target object is genuinely present. In particular, reject ordinary
speaker/projection/presentation images from the `smart_speaker` proxy set.

Official instructions:
https://storage.googleapis.com/openimages/web/download_v7.html

## Public direct dataset export

For an already downloaded or direct-public Roboflow export:

```powershell
python data_tools\ingest_public_dataset.py `
  --source-dir downloaded_dataset\train\images `
  --output candidate_data\known_safe\laptop `
  --object-class laptop --dataset-name example_dataset `
  --source-url https://universe.roboflow.com/example/public-dataset `
  --license "CC BY 4.0" `
  --license-url https://creativecommons.org/licenses/by/4.0/
```

`--download-url` may point to a public HTTPS ZIP without tokens. URLs containing
API keys or access tokens are rejected. ZIP size is limited and path traversal
is rejected.

## Training-only augmentation

```powershell
python -m venv .venv-data
.\.venv-data\Scripts\python.exe -m pip install -r data_tools\requirements.txt
.\.venv-data\Scripts\python.exe data_tools\augment_dataset.py `
  --input train\laptop --output train_augmented\laptop --multiplier 10
```

This stage requires no credentials. Before training, obtain enough diverse,
licensed images for each class and keep an untouched held-out test set.
