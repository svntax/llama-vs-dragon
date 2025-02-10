# llama-vs-dragon
A simple game about a llama's encounter with a deadly dragon.

![llama vs dragon screenshot](https://github.com/user-attachments/assets/1bb84994-5b71-4f4a-b147-f3bb06d5200e)

This project is more of an example demo/prototype than a full game, mainly to test out the [NobodyWho plugin](https://github.com/nobodywho-ooo/nobodywho) for Godot.

## Setup
1. Clone the repository and open the project.
2. Install NobodyWho v4.5.0
3. Download an LLM and embedding model of your choice. This game uses [gemma-2-2b-it](https://huggingface.co/bartowski/gemma-2-2b-it-GGUF) for the chat model and [bge-m3](https://huggingface.co/vonjack/bge-m3-gguf) for the embedding model.

### Gameplay
The player is a llama trying to convince the dragon to give away some treasure. If you anger the dragon too much, you die.

The embedding model is meant to be used to analyze if at any point the dragon has either a) given away treasure, or b) killed the player, but it doesn't work very well. At the very least, you can continue to chat with the dragon even after either of these actions are triggered.

## Credits
- Ruler 9 font by somepx (https://somepx.itch.io/free-font-ruler)
- Thanks to the [demo game](https://github.com/nobodywho-ooo/nobodywho/tree/main/demo-game) from NobodyWho, which this project is based off of.
