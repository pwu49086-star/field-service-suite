{
  "$id": "field-service://schemas/{{module-name}}-asset-extension",
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "{{Industry}} Asset Extension",
  "description": "{{Industry}}-specific fields stored in the Asset.extension JSON field.",
  "type": "object",
  "properties": {
    "_template_note": {
      "type": "string",
      "description": "Replace all fields below with your industry-specific fields."
    },
    "exampleField1": {
      "type": "string",
      "description": "Replace with your first industry-specific field"
    },
    "exampleField2": {
      "type": "number",
      "description": "Replace with your second industry-specific field"
    }
  },
  "required": ["exampleField1"]
}
