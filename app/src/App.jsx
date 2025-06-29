import { useEffect, useState } from "react";
import { ethers } from 'ethers'
import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import Menu from './pages/Menu'

import config from "./artifacts/contracts/contract.sol/Contract.json"
import Lk from "./pages/Lk";

import 'bootstrap/dist/css/bootstrap.css';
import Start from "./pages/Start";
import SetNftToId from "./pages/SetNftToId";
import Active from "./pages/Active";

let contract = null

function App() {

  const [signer, setSigner] = useState(null)
  const [provider, setProvider] = useState(null)

  useEffect(() => {
    const usContract = async () => {
      try {
        contract = new ethers.Contract(config.address, config.abi, provider)
      } catch (e) {
        alert(e)
      }
    }

    
    usContract()
  }, [signer, provider])



  window.ethereum.on('accountsChanged', () => {window.location.reload()})
  window.ethereum.on('chainChanged', () => {
    window.location.reload()
    alert('Вы изменили сеть, наше решение работает только с сетью Hardhat')
  })

  return (
    <div >
    
      <BrowserRouter>

        <Menu 
          signer={signer}
          setSigner={setSigner}
          provider={provider}
          setProvider={setProvider}
        />

        {provider
          ?
            <Routes>
              <Route path='/lk' element={<Lk signer={signer} contract={contract}/>}></Route>
              <Route path='/lk/:id' element={<SetNftToId signer={signer} contract={contract}/>}></Route>
              <Route path='/active' element={<Active signer={signer} contract={contract}/>}></Route>
              <Route path='*' element={<Navigate to='/lk' />}></Route>
            </Routes>
          :
          <Routes>
            <Route path='/' element={<Start />}></Route>
            <Route path='*' element={<Navigate to='/' />}></Route>
          </Routes>
        }
      </BrowserRouter>

    </div>
  );
}

export default App;
