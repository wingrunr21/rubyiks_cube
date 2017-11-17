import React from 'react'
import {connect} from 'react-redux'
import CubeAnimation from 'roofpig'
import Cube from 'cubejs'

class Roofpig extends React.Component {
  static defaultProps = {
    roofpigId: 'roofpig_root'
  }

  constructor(props) {
    super(props)

    this.state = {
      roofpigConfig: this.roofpigConfig(props)
    }
  }

  componentDidMount() {
    CubeAnimation.initialize()
    this.mountRoofpig()
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      roofpigConfig: this.roofpigConfig(nextProps)
    })
  }

  componentWillUpdate(nextProps, nextState) {
    this.roofpig.remove()
  }

  componentDidUpdate(prevProps, prevState) {
    this.mountRoofpig()
  }

  mountRoofpig(config) {
    this.roofpig = CubeAnimation.create_in_dom(this.refs.roofpig, `data-config="${this.state.roofpigConfig}"`, 'class="roofpig" style="height:500px;width:500px;margin:auto;')
  }

  roofpigConfig(data) {
    const tweaks = this.cubeToTweaks(data.cubeState).join(' ')
    return `pov=Ufr|algdisplay=2p|flags=showalg startsolved|hover=far|speed=150|colors=R:b L:g F:o B:r U:y D:w|alg=${data.solution}|tweaks=${tweaks}`
  }

  cubeToTweaks(cubeState) {
    const facelets = [
      'Ulb','Ub','Urb','Ul','U','Ur','Ulf','Uf','Urf',
      'Ruf','Ru','Rub','Rf','R','Rb','Rfd','Rd','Rbd',
      'Ful','Fu','Fur','Fl','F','Fr','Fdl','Fd','Fdr',
      'Dfl','Df','Dfr','Dl','D','Dr','Dbl','Db','Dbr',
      'Lub','Lu','Luf','Lb','L','Lf','Ldb','Ld','Ldf',
      'Bur','Bu','Bul','Br','B','Bl','Bdr','Bd','Bdl',
    ]
    return cubeState.split('').map((face, i) => {
      const facelet = facelets[i]
      return `${face}:${facelet}`
    })
  }

  render() {
    return (
      <div id={this.props.roofpigId} ref='roofpig' />
    )
  }
}
export default connect(
  state => state.cube,
  {}
)(Roofpig)