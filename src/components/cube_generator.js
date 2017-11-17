import React from 'react'
import Cube from 'cubejs'
import {connect} from 'react-redux'

import {sendAndSetCubeState} from 'state/cube'

const CubeGenerator = ({cubeState, sendAndSetCubeState}) => {
  const generateCube = () => (
    sendAndSetCubeState(Cube.random().asString())
  )
  return (
    <div style={{flex: 1}}>
      <h3>{cubeState}</h3>
      <button onClick={generateCube}>Generate Random Cube</button>
    </div>
  )
}
export default connect(
  state => ({cubeState: state.cube.cubeState}),
  {sendAndSetCubeState}
)(CubeGenerator)
