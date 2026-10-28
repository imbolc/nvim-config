# Agents guideline

It's a repo for a Neovim configuration.

## LSP

The config is used native Nvim LSP capabilities with configs located in `./lsp/`

## Conventions

- The entire configuration is in `./init.lua`. Keep it that way; never split the
  file.
- Follow the existing code style consistently.
- Check the current Nvim version with `vim --appimage-extract-and-run --version`
  and make sure the code you write is compatible.

## Chatting

- If I ask you a question, don't automatically assume it's an implementation
request. Answer the question first and then ask if you should implement the
suggested solution.

## Coding tasks

- Always document any code you add. In the comment, explain what the code does
  and its purpose in the context of the task
- After you're done with a coding task make `./.pre-commit.sh` pass

## Git

- After finishing a coding task, suggest a commit message and ask if you should
  commit changes
