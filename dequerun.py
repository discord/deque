import discord

client = discord.Client()

@client.event
async def on_message(message):
    if message.content == "!run":
        # Get the code from the message
        code = message.content[5:]

        # Run the code
        try:
            result = eval(code)
        except Exception as e:
            result = str(e)

        # Send the result back to the user
        await message.channel.send(result)

client.run("YOUR_TOKEN")
