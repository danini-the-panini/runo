import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['deck', 'discard', 'playerCards', 'otherPlayerCards', 'otherCard', 'runo']

  runoTargetConnected(runo) {
    requestAnimationFrame(() => {
      runo.classList.add('animated')
      setTimeout(() => {
        runo.classList.add('disappear')
        setTimeout(() => {
          runo.remove()
        }, 300)
      }, 1000)
    })
  }

  connect() {
    if (!this.hasDeckTarget) return

    const deckBounds = this.deckTarget.getBoundingClientRect()
    let i = 0
    for (let card of this.otherCardTargets) {
      if (card.dataset.drawn !== 'true') continue;
      const svg = card.querySelector('svg')
      const bounds = svg.getBoundingClientRect()
      const dx = deckBounds.x - bounds.x
      const dy = deckBounds.y - bounds.y
      svg.style.transition = 'none'
      svg.style.transform = `translate(${dx}px, ${dy}px)`
      svg.style.transitionDelayi = `${i*100}ms`
      setTimeout(() => {
        svg.style.transition = null
        svg.style.transform = null
      }, i*100)
      i++
    }

    if (this.discardTarget.dataset.player) {
      const player = this.otherPlayerCardsTargets.find(p => p.dataset.player === this.discardTarget.dataset.player)
      const playerBounds = player.lastElementChild.getBoundingClientRect()
      const svg = this.discardTarget.querySelector('svg')
      const bounds = svg.getBoundingClientRect()
      const dx = playerBounds.right - bounds.x
      const dy = playerBounds.y - bounds.y
      svg.style.transition = 'none'
      svg.style.transform = `translate(${dx}px, ${dy}px)`
      requestAnimationFrame(() => {
        svg.style.transition = null
        svg.style.transform = null
      })
    }
  }

  play({ currentTarget }) {
    const card = currentTarget.closest('.card')
    const svg = card.querySelector('svg')
    const bounds = svg.getBoundingClientRect()
    const discardBounds = this.discardTarget.getBoundingClientRect()
    const dx = discardBounds.x - bounds.x
    const dy = discardBounds.y - bounds.y
    svg.style.transform = `translate(${dx}px, ${dy}px)`
  }

  draw({ currentTarget }) {
    const svg = currentTarget.querySelector('svg')
    const bounds = svg.getBoundingClientRect()
    const playBounds = this.playerCardsTarget.lastElementChild.getBoundingClientRect()
    const dx = playBounds.right - bounds.x
    const dy = playBounds.y - bounds.y
    svg.style.transform = `translate(${dx}px, ${dy}px)`
  }
}
