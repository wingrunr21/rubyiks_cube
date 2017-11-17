// @flow
import {createStore, combineReducers, applyMiddleware} from 'redux'
import {composeWithDevTools} from 'redux-devtools-extension'
import thunk from 'redux-thunk'
import reducer from 'state/cube'
import connection from 'state/socket'

const rootReducer = combineReducers({
  cube: reducer
})

const store = createStore(rootReducer,
  composeWithDevTools(
    applyMiddleware(thunk.withExtraArgument(connection))
  )
)

export default store
