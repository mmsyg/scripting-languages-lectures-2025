import os
import discord
from discord.ext import commands
from dotenv import load_dotenv
import ollama
import json

#load token from env
load_dotenv('.env')
token = os.getenv('DISCORD_TOKEN')


tournaments = {}
players = {}
user_states = {}

#prompt chains
t_INTENT = (
    "You are an intent detection assistant for an eSports chatbot.\n"
    "Return one of: TOURNAMENT_LIST, JOIN_TOURNAMENT, STATUS, UNKNOWN."
)
t_TOURNAMENT_INTRO = (
    "One-sentence thank you for interest. Do NOT list tournaments, or give your opinion; message after you  will do that"
)
t_STATUS_INTRO = (
    "One-sentence to say that you shw the tournaments. Do NOT list tournaments, or give your opinion; message after you  will do that"
)

#call ollama3
def ask_llm(messages):
    try:
        res = ollama.chat(model="llama3", messages=messages)
        return res.get('message', {}).get('content','').strip()
    except Exception as e:

        print("LLM error:", e)
        return ""



def is_yes(ans):
    return ans.lower() in ["yes", "y", "sure", "ok", "yeah", "okey"]



#bot setup
intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    #tournamnts
    tournaments.update({
        'CS:GO': {'status': 'Open', 'details': '8 teams'},
        'FIFA': {'status': 'Open', 'details': '16 teams'},
        'Rocket League': {'status': 'Open', 'details': '12 teams'}
    })
    print('Bot is ready as', bot.user)




@bot.event
async def on_message(message):
    if message.author.bot:
        return
    uid = message.author.id
    state = user_states.get(uid, {})
    content = message.content.strip()
    content_lower = content.lower()



    if content_lower.startswith('add ') or ('sign ' in content_lower and ' to ' in content_lower):
        parsed = ask_llm([
            {'role': 'system', 'content': (
                "You are a parsing assistant.\n"
                "Given input like 'sign xyz123 to FIFA', extract JSON with keys 'nick' and 'tournament'.\n"
                "Return only the JSON object."
            )},
            {'role': 'user', 'content': content}
        ])

        try:
            data = json.loads(parsed)
            nick = data.get('nick')
            tourney = data.get('tournament')
        except json.JSONDecodeError:

            await message.channel.send("Could not parse nick or tournament. Use format: sign <nick> for <tournament>.")
            return
        
        #validate
        match = next((t for t in tournaments if t.lower() == tourney.lower()), None)
        if not match:

            await message.channel.send(f"Tournament '{tourney}' not found.")
            return
        
        players.setdefault(match, []).append(nick)
        num = len(players[match])
        info = tournaments[match]

        await message.channel.send(
            f"{nick} has joined {match} as player #{num}. Details: {info['details']} (Status: {info['status']})"
        )
        return

    #multi-step join if there is not nick and tournament in join message
    if state.get('step') == 'confirm':

        if is_yes(content):
            await message.channel.send('Please enter your nickname:')
            state['step'] = 'get_nick'
        else:
            await message.channel.send('Alright, let me know anytime!')
            user_states.pop(uid, None)
        return

    if state.get('step') == 'get_nick':
        state['nick'] = content
        await message.channel.send('Which tournament? Options: ' + ', '.join(tournaments.keys()))
        state['step'] = 'get_tournament'
        return


    if state.get('step') == 'get_tournament':
        choice = content
        if choice not in tournaments:
            await message.channel.send(f"Tournament '{choice}' not found.")
            return
        
        players.setdefault(choice, []).append(state['nick'])
        num = len(players[choice])
        info = tournaments[choice]
        await message.channel.send(
            f"{state['nick']} has joined {choice} as player #{num}. Details: {info['details']} (Status: {info['status']})"
        )
        user_states.pop(uid, None)

        return

    #detect intent
    intent = ask_llm([
        {'role': 'system', 'content': t_INTENT},
        {'role': 'user', 'content': content}
    ]).upper()

    #list tournaments
    if 'LIST' in intent:
        intro = ask_llm([
            {'role': 'system', 'content': t_TOURNAMENT_INTRO},
            {'role': 'user', 'content': content}
        ])
        reply = f"{intro}\n\nAvailable tournaments:\n"
        for name, info in tournaments.items():
            reply += f"- {name}: {info['status']} ({info['details']})\n"
        await message.channel.send(reply)

    # join
    elif 'JOIN' in intent:
        await message.channel.send('Do you want to join a tournament? (yes/no)')
        user_states[uid] = {'step': 'confirm'}

    #show status
    elif 'STATUS' in intent:
        intro = ask_llm([
            {'role': 'system', 'content': t_STATUS_INTRO},
            {'role': 'user', 'content': content}
        ])
        txt = f"{intro}\n\nTournament status:\n"
        for name, info in tournaments.items():
            pls = players.get(name, [])
            if pls:
                txt += f"{name}: {', '.join(pls)}\n"
            else:
                txt += f"{name}: (no players)\n"
        await message.channel.send(txt)

    #missunderstood
    else:
        await message.channel.send('Huh? I did not get that. Try list/join/status.')



bot.run(token)
