<script>
  import playerRoutes from "../api/PlayersApi";
  import gameRoutes from "../api/GamesApi";

  const { game } = $props();

  async function start() {
    await gameRoutes.update(game);
  }

  async function join() {
    await playerRoutes.create({ game_id: game.id });
  }

  async function leave() {
    await playerRoutes.destroy({ game_id: game.id });
  }
</script>

{#if game.players.length < 2}
  <h2>Waiting for more players...</h2>
{:else}
  <h2>Ready to start!</h2>
  {#if game.yours}
    <button onclick={start}>Start!</button>
  {/if}
{/if}

<ul>
  {#each game.players as player}
    <li>{player.name}</li>
  {/each}
</ul>

{#if game.joined}
  {#if !game.yours}
    <button onclick={leave}>Leave</button>
  {/if}
{:else}
  <button onclick={join}>Join!</button>
{/if}
