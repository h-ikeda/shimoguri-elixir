import {Socket} from 'phoenix'
import LiveSocket from 'phoenix_live_view'

const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
const liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: {
    authorize: {
      async mounted() {
        const response = await fetch('/api/authorize_url')
        const data = await response.json()
        Object.entries(data).forEach(([provider, url]) => {
          this.el.querySelector(`a.${provider}`).href = url
        })
      }
    }
  }
})

liveSocket.connect()
