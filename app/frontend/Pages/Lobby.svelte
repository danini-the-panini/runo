<script>
  import { onMount, onDestroy } from "svelte";
  import { router, Link } from "@inertiajs/svelte";
  
  import LogoSvg from "../assets/images/logo.svg?raw";
  import gameRoutes from "../api/GamesApi";
  import consumer from "../channels/consumer";

  let yourGames = $state(null);
  let games = $state(null);

  onMount(async () => {
    const res = await gameRoutes.index();
    yourGames = res.yourGames;
    games = res.games;
  });

  async function newGame() {
    let game = await gameRoutes.create();
    router.visit(gameRoutes.show.path(game));
  }

  let subscription = consumer.subscriptions.create("LobbyChannel", {
    received(data) {
      console.log(data);
      switch (data.type) {
      case "create":
        games.push(data.game);
        break;
      case "update":
        const game = games.find(g => g.id === data.game.id);
        if (game) Object.assign(game, data.game);
        break;
      case "destroy":
        games = games.reject(g => g.id === data.id);
        break;
      }
    }
  });

  onDestroy(() => {
    consumer.subscriptions.remove(subscription);
  });
</script>

<div class="logo logo-small">{@html LogoSvg}</div>

<h2>Games</h2>


<h3>Your games</h3>
{#if yourGames }
  {#if yourGames.length}
    <ul>
      {#each yourGames as game (game.id)}
        <li id={game.id}>
          <Link href={gameRoutes.show.path(game)}>#{game.id} - {game.playerCount} player(s)</Link>
        </li>
      {/each}
    </ul>
  {:else}
    <p>No games</p>
  {/if}
{:else}
  <p>Loading...</p>
{/if}

<h3>Lobby</h3>
{#if games}
  {#if games.length}
    <ul>
      {#each games as game}
        <li>
          <Link href={gameRoutes.show.path(game)}>#{game.id} - {game.playerCount} player(s)</Link>
        </li>
      {/each}
    </ul>
  {:else}
    <p>No games</p>
  {/if}
{:else}
  <p>Loading...</p>
{/if}

<button onclick={newGame}>New game</button>
