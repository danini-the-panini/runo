<script>
  import turnRoutes from "../api/TurnsApi";
  import Card from "../Components/Card.svelte";
  import CardBackSvg from "../assets/images/cards/back.svg?raw";

  const { game, update } = $props();

  async function play(card) {
    const data = await turnRoutes.create({ params: { game_id: game.id }, data: { play: "card", card_id: card.id } })
    update(data);
  }
</script>

<h2>
  {#if game.yourTurn}
    Your turn!
  {:else}
    {game.players.find(p => p.current).name}'s turn
  {/if}
  <div>
    {#if game.plus > 0}
      Stack: {game.plus}
    {/if}
  </div>
  <div>
    {#if game.dir < 0}
      Reversed!
    {/if}
  </div>
  <div>
    {#if game.top.color === "wild"}
      Color: {game.color}
    {/if}
  </div>
  <div class="players-area">
    <div class="players-list">
      {#each game.players as player (player.id)}
        <div class="player {player.current ? 'current-player' : ''}">
          <div class="player-info">
            <strong>{player.name}</strong>
            {#if player.current}
              <span class="turn-indicator">Current Turn</span>
            {/if}
            {#if player.card_count === 1 && !player.runo}
              <button onclick={youDidntSayRuno} class="runo-button">You didn't say rUNO!</button>
            {/if}
          </div>
          <ul class="other-player-cards">
            {#each Array(player.cardCount) as _, index (index)}
              <li class="card other-player-card">
                {@html CardBackSvg}
              </li>
            {/each}
          </ul>
          {#if false && (player.saidSomethingRuno)}
            <div class="runo">
              {#if runo}
                rUNO!
              {:else}
                You didn't say rUNO!
              {/if}
            </div>
          {/if}
        </div>
      {/each}
    </div>
  </div>
  <div class="play-area">
    <div class="discard">
      <div class="deck-stack" style="width: {(game.discardSize-1)*0.5}px"></div>
      <div class="discard-card card card-{game.top.color}">
        <Card card={game.top} />
      </div>
    </div>
    <div class="deck">
      <div class="deck-stack" style="width: {(game.discardSize-1)*0.5}px"></div>
      <div class="card deck-next-card">{@html CardBackSvg}</div>
      <div class="card deck-card {game.canDraw ? 'playable' : ''}">
        {#if game.canDraw}
          <button onclick={draw} class="card-button">
            {@html CardBackSvg}
          </button>
        {:else}
          {@html CardBackSvg}
        {/if}
      </div>
    </div>
  </div>
  <div class="my-hand">
    {#if game.cards.length === 1 && !game.runo}
      <button onclick={runo} class="runo-button">rUNO!</button>
    {/if}
    <ul class="cards">
      {#each game.cards as card (card.id)}
        <li class="
          card
          card-{card.color}
          {game.yourTurn && card.place ? 'playable' : ''}
          {game.yourTurn && !card.place ? 'unplayable' : ''}
        ">
          {#if game.yourTurn && card.place}
            {#if card.color === "wild"}
              <button onclick={() => playWild(card)} class="card-button">
                <Card card={card} />
              </button>
              <dialog>
                {#each ["red", "yellow", "green", "blue"] as color}
                  <button onclick={() => chooseColor(color, card)}>{color}</button>
                {/each}
              </dialog>
            {:else}
              <button onclick={() => play(card)} class="card-button">
                <Card card={card} />
              </button>
            {/if}
          {:else}
            <Card card={card} />
          {/if}
        </li>
      {/each}
    </ul>
  </div>
</h2>
