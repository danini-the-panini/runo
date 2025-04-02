<script>
  const { game } = $props();
</script>

<h2>
  {#if game.winner === 'you'}
    You win!
  {:else}
    {game.winner} wins!
  {/if}
</h2>
