<script>
  import { onDestroy } from "svelte";
  import { router, Link } from "@inertiajs/svelte";

  import gameRoutes from "../api/GamesApi";
  import consumer from "../channels/consumer";

  import LobbyGame from "../Components/LobbyGame.svelte";
  import PlayingGame from "../Components/PlayingGame.svelte";
  import FinishedGame from "../Components/FinishedGame.svelte";
  import AbandonedGame from "../Components/AbandonedGame.svelte";

  let { game } = $props();

  let gameState = $state(game);

  async function abandon() {
    await gameRoutes.destroy(game);
    router.visit("/");
  }

  function update(game) {
    gameState = game;
  }

  let subscription = consumer.subscriptions.create({
    channel: "GameChannel",
    game_id: game.id,
  }, {
    received(data) {
      console.log(data);
      update(data)
    }
  });

  onDestroy(() => {
    consumer.subscriptions.remove(subscription);
  });
</script>

<h1>{game.user}'s game</h1>

{#if game.status === "lobby"}
  <LobbyGame game={gameState} />
{:else if game.status === "playing"}
  <PlayingGame game={gameState} update={update} />
{:else if game.status === "finished"}
  <FinishedGame game={gameState} />
{:else if game.status === "abandoned"}
  <AbandonedGame />
{/if}

{#if gameState.yours && (gameState.status === "lobby" || gameState.status === "playing")}
  <button onclick={abandon}>Abandon</button>
{/if}

<Link href="/">Back to lobby</Link>

