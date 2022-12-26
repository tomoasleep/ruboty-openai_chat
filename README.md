# Ruboty::OpenAIChat

[OpenAI](https://openai.com/) responds to given message if any other handler does not match.

This gem uses conversation with an AI assistant like https://beta.openai.com/examples/default-chat as prompt for OpenAI.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ruboty-openai-chat

## Commands

```
ruboty /remember chatbot profile (?<body>.+)/ - Remembers given sentence as pretext of AI prompt
ruboty /show chatbot profile/ - Show the remembered profile
```

### ENV

- `OPENAI_ACCESS_TOKEN` - Pass OpenAI ACCESS TOKEN
- `OPENAI_ORGANIZATION_ID` - Pass OpenAI Organization ID"
- `OPENAI_CHAT_PRETEXT` -
- `OPENAI_CHAT_LANGUAGE` - Pass your primary language", optional: true
- `OPENAI_CHAT_MEMORIZE_SECONDS` - AI

## Development

See: [HOW_TO_DEVELOPMENT.md](./HOW_TO_DEVELOPMENT.md)
