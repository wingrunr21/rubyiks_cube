import {createActions, handleActions} from 'redux-actions'

const SOLVED_CUBE = 'UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB'
const DEFAULT_SOLUTION = ''

const defaultState = {
  cubeState: SOLVED_CUBE,
  computeTime: 0.0,
  solution: DEFAULT_SOLUTION
}

export const {setCubeState, setCubeSolution} = createActions('SET_CUBE_STATE', 'SET_CUBE_SOLUTION')

export function sendAndSetCubeState(cubeState) {
  return (dispatch, getState, connection) => {
    try {
      connection.send(cubeState)
    } catch (e) {
      console.log(e)
    }
    dispatch(setCubeState(cubeState))
  }
}

const reducer = handleActions({
  SET_CUBE_STATE: (state, action) => ({
    ...state,
    cubeState: action.payload,
    solution: DEFAULT_SOLUTION
  }),

  SET_CUBE_SOLUTION: (state, action) => ({
    ...state,
    ...action.payload
  })
}, defaultState)
export default reducer
