<h1 align="center">
	JOIN THE DISCORD FOR SUPPORT
</h1>

<img src="https://i.gyazo.com/3894b03d4351bcb566ec85afc7f9b231.png">

<h4 align="center">
	<a href="https://github.com/JokeDevil-com/JD_logs/releases/latest" title=""><img alt="Licence" src="https://img.shields.io/github/release/JokeDevil-com/JD_logs.svg"></a>
	<a href="LICENSE" title=""><img alt="Licence" src="https://img.shields.io/github/license/JokeDevil-com/JD_logs.svg"></a>
	<a href="https://discord.gg/qyPdHzDKmb" title=""><img alt="Discord Status" src="https://discordapp.com/api/guilds/721339695199682611/widget.png"></a>
</h4>

https://discord.gg/prefech

<h4 align="center">
This is a server log script for FiveM, which is used to log certain actions that are being made in the server.
</h5>

### 🛠 Requirements
- A Discord Server
- FXServer

### ✅ Main Features
- Basic logs:
  - Chat Logs (Messages typed in chat)
  - Join Logs (When i player is connecting to the sever)
  - Leave Logs (When a player disconnects from the server)
  - Death Logs (When a player dies/get killed)
  - Shooting Logs (When a player fires a weapon)
  - Resource Logs (When a resouce get started/stopped)
- Plugin Support
  - Easy way to add more logs to JD_logs with plugins. (More plugins will be released soon!)
- Optional custom logs
  - Easy to add with the export.

### 🔧 Download & Installation

1. Download the files
2. Put the JD_logs folder in the server resource directory
3. Add this to your `server.cfg`
```
ensure JD_logs
```

### 📝 Creating Custom Logs

1. Add the following code to your function/command.<br>
*This code needs to be added in the resource of the action you want to log.*
```
exports.JD_logs:discord('EMBED_MESSAGE', PLAYER_ID, PLAYER_2_ID, 'COLOR', 'WEBHOOK_CHANNEL')
```
`EMBED_MESSAGE`: This will be the message send in the top of the embed.<br>
`PLAYER_ID`: This will send the player to the script to get the info. (This needs to be a server id)<br>
`PLAYER_2_ID`: This will send the second player's to the script to get the info. (This needs to be a server id)<br>
`COLOR`: This will be the color of the embed. (You can use Decimal colors or Hex colors.)<br>
`WEBHOOK_CHANNEL`: This will be the webhook channel listed in the config.lua.<br>


2. Create a discord channel with webhook and add this to the webhooks.
```
local webhooks = {
	all = "DISCORD_WEBHOOK",
	chat = "DISCORD_WEBHOOK",
	joins = "DISCORD_WEBHOOK",
	leaving = "DISCORD_WEBHOOK",
	deaths = "DISCORD_WEBHOOK",
	shooting = "DISCORD_WEBHOOK",
	resources = "DISCORD_WEBHOOK",
	WEBHOOK_CHANNEL = "DISCORD_WEBHOOK", <------
}
```
*This can be found in the `config.lua`*

### ❓ For more questions you can join the discord here: https://discord.gg/prefech