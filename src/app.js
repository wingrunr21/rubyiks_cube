import React from 'react';
import Cube from 'components/cube'
import CubeGenerator from 'components/cube_generator'

const App = () => (
  <section style={{fontFamily: 'Source Code Pro'}}>
    <h1 style={{textAlign: 'center'}}>Rubyik's Cube Web 5000</h1>
    <div style={{display: 'flex'}}>
      <Cube />
      <CubeGenerator />
    </div>
  </section>
)
export default App