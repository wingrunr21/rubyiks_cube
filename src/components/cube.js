import React from 'react'
import {connect} from 'react-redux'
import Roofpig from 'components/roofpig'

const Cube = ({computeTime}) => {
  return (
    <div style={{flex: 1, position: 'relative'}}>
      <h3 style={{textAlign: 'center'}}>{computeTime}s to compute solution</h3>
      <Roofpig />
    </div>
  )
}

export default connect(
  state => state.cube,
  {}
)(Cube)
