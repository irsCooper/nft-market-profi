import { ethers } from "ethers";
import React, { useCallback } from "react";
import {Button, Navbar, Nav, Container, Offcanvas} from 'react-bootstrap'
import { Link } from "react-router-dom";

export default function Menu({
    signer,
    setSigner,
    provider,
    setProvider
}) {


    const onConnect = useCallback(async () => {
        if(window.ethereum) {
            const _provider = new ethers.BrowserProvider(window.ethereum)
            // const _provider = new ethers.getDefaultProvider()
            console.log(_provider)
            const sig = await _provider.getSigner()
            setProvider(_provider)
            setSigner(sig)

            console.log(signer)
            console.log(provider)
        } else {
            alert('invail metamask')
            onclick(window.location.reload())
            let _provider = ethers.getDefaultProvider()
            setProvider(_provider)
            setSigner(null)
        }
    })




    return(
        <header>
            <Navbar bg='dark' data-bs-theme='dark'>
                <Container>
                    <Navbar.Brand>Профессионалы</Navbar.Brand>

                    {signer
                        ?
                            <Nav>
                                <Nav.Link><Link style={{color: 'grey'}} to='/active'>Активы</Link></Nav.Link>
                                <Nav.Link><Link style={{color: 'grey'}} to='/lk'>Личный кабинет</Link></Nav.Link>
                                <Button variant="danger" className="mr-2" onClick={() => window.location.reload()}>Выйти</Button>
                            </Nav>
                        :
                            <Nav>
                                <Button variant="success" className="mr-2" onClick={onConnect} >Подключить кошелёк</Button>
                            </Nav>
                    }
                </Container>
            </Navbar>
        </header>
    )
}
