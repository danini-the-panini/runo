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

  async function abandon() {
    await gameRoutes.destroy(game);
    router.visit("/");
  }

  let subscription = consumer.subscriptions.create({
    channel: "GameChannel",
    game_id: game.id,
  }, {
    received(data) {
      console.log(data);
      game = data;
    }
  });

  onDestroy(() => {
    consumer.subscriptions.remove(subscription);
  });
</script>

<h1>{game.user}'s game</h1>

{#if game.status === "lobby"}
  <LobbyGame game={game} />
{:else if game.status === "playing"}
  <PlayingGame game={game} />
{:else if game.status === "finished"}
  <FinishedGame game={game} />
{:else if game.status === "abandoned"}
  <AbandonedGame />
{/if}

{#if game.yours && (game.status === "lobby" || game.status === "playing")}
  <button onclick={abandon}>Abandon</button>
{/if}

<Link href="/">Back to lobby</Link>

