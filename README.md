# HassBot

HassBot is the chat assistant for the [Home Assistant chatrooms](https://gitter.im/home-assistant/home-assistant) on Gitter.

## Purpose

The goal of HassBot is to help productivity in providing support to other users of Home Assistant.
  1. HassBot should have a personality and sense of humor as part of being productive. Please do not submit entertainment scripts with no practical use for productivity.
  2. HassBot should not flood the chat rooms, keep responses as short as possible or respond with a private message for longer responses.
  3. HassBot should not annoy, insult, or harrass users. This includes scripting that returns false positives and posting when it shouldn't.

## Contribute

Feel free to contribute to the evolution of HassBot.
  1. Fork the HassBot repository at https://github.com/home-assistant/hassbot.
  2. Get a local copy: `git clone https://github.com/[your_username]/hassbot.git`
  3. Add our branch for rebasing: `git remote add upstream https://github.com/home-assistant/hassbot.git`
  4. Create a new working branch: `git checkout -b [new_branch]`
  5. Make your changes.
  6. Stage your changes: `git add .`
  7. Commit your changes: `git commit -m "[Add a brief description of changes.]"`
  8. Upload changes to your fork: `git push origin [branch_name]`
  9. Compare and Submit Pull Request to the dev branch on GitHub.com.

## Testing
  1. Create a separate Gitter user for testing.
  2. Join the new user to a chat with your main account.
  3. Get your Gitter Personal Access Token for the test user at https://developer.gitter.im
  4. Run `$ HUBOT_GITTER2_TOKEN=[Test_user_personal_access_token] ./bin/hubot -a gitter2 --name [test-user-name]`

## Considerations
[hubot](http://hubot.github.com)
[Home Assistant](https://home-assistant.io)
