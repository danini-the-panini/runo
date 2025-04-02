<script>
  const cardSvgs = import.meta.glob("../assets/images/cards/*.svg", { as: "raw" });
  console.log(cardSvgs)

  const { card } = $props();
  let name = `../assets/images/cards/${card.face}`;
  if (card.plus > 0) name += `_${card.plus}`;
  name += '.svg';
  const svgPromise = cardSvgs[name]();
</script>

{#await cardSvgs[name]()}
{:then svg}
  {@html svg.replace(/#FF00FF/g, "currentColor")}
{:catch}
  <div class="card-error">ERROR</div>
{/await}
