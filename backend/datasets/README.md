# Nirapod AI offline datasets

Datasets are deliberately not downloaded or trained during FastAPI startup.
Place source files under `raw/` using the names recorded in `sources.json`.
The raw directory is excluded from source control because feeds can be large
and their redistribution conditions may differ from their usage conditions.

Optional reviewed native-language messages may be placed in
`reviewed_messages.tsv` with three tab-separated columns:

`label<TAB>language<TAB>text`

Allowed labels are `benign`, `spam`, `phishing`, and `scam`; allowed languages
are `en`, `bn`, and `ms`. Machine translations must be marked in a separate
provenance record and must never be used as the only Bangla or Malay test data.

Run `python train_models.py` from the backend virtual environment. Artifacts are
written to `models/candidate/`; they are not used by the API until independently
reviewed and promoted in `models/model_manifest.json`.
