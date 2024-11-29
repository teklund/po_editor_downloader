## POEditor Downloader
CLI tool for simple way of updating translations in flutter projects from [POEditor](https://poeditor.com/).

---
### How to use
```sh
dart run po_editor_downloader --api_token=key --project_id=id
```

### Parameters 
- api_token - API token from POEditor
- project_id - Project ID from POEditor
- files_path - (optional) Path where you want to save the downloaded files relative to where you run the script. Will default to "lib/l10n/"
- tags - (optional) Filter results by tags; you can use either a string for a single tag or a JSON array for one or multiple tags
- filter - (optional) Filter results by 'translated', 'untranslated', 'fuzzy', 'not_fuzzy', 'automatic', 'not_automatic', 'proofread', 'not_proofread' (only available when proofreading is enabled for the project in its settings); you can use either a string for a single filter or a JSON array for one or multiple filter

### API Reference
- [POEditor API Reference](https://poeditor.com/docs/api)
 
