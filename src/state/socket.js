import {setCubeSolution} from 'state/cube'
import store from 'state/store'

const connection = new WebSocket('ws://localhost:9292')

// connection.onopen = () => {}
connection.onmessage = event => {
  console.log(`Receved solution ${event.data}`)
  const data = JSON.parse(event.data)
  store.dispatch(setCubeSolution(data))
}
connection.onclose = event => { console.log(event) }

export default connection
