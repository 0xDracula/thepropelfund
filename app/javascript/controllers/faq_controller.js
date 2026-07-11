import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "answer"]

  toggle(event) {
    const index = this.buttonTargets.indexOf(event.currentTarget)
    const wasOpen = this.buttonTargets[index].classList.contains("open")

    this.buttonTargets.forEach((button, i) => {
      const open = !wasOpen && i === index
      button.classList.toggle("open", open)
      this.answerTargets[i].hidden = !open
    })
  }
}
