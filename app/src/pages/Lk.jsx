import React, { useEffect, useState } from "react";
import Nft from "./Nft";
import Collection from "./Collection";
import { Button, Form, Modal } from 'react-bootstrap'

export default function Lk({
    signer,
    contract
}) {
    const [user, setUser] = useState(null)
    const [ball, setBall] = useState(null)
    
    const [nft, setNft] = useState([])
    const [collection, setCollection] = useState([])

    useEffect(() => {
        const interval = setInterval(async () => {
            let u = await contract.connect(signer).auth()
            setUser(u[0])
            setBall(u[1].toString())

            let n = await contract.connect(signer).getUserNft()
            setNft(n)

            let c = await contract.connect(signer).getUserCollection()
            setCollection(c)
        }, 100)

        return () => {
            clearInterval(interval)
        }
    }, [])

    const [col, setCol] = useState({name: '', desc: ''})

    const sCol = async (e) => {
        e.preventDefault()
        console.log(col)
        try {
            const res = await contract.connect(signer).setCollection(col.name, col.desc)
            console.log(res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
        } catch(err) {
            alert(err)
            console.log(err)
        }
    }


    const [show, setShow] = useState(false);
    const [_nft, set_Nft] = useState({name: '', desc: '', file: '', price: 0, amount: 0})

    const file = (e) => {
        const file = e.target.files[0]
        set_Nft({..._nft, file: file.name})
    }

    const sNft = async (e) => {
        e.preventDefault()

        try {
            const res = await contract.connect(signer).setNft(_nft.name, _nft.desc, _nft.file, _nft.price, _nft.amount, true) 
            console.log(res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
        } catch(err) {
            console.log(err)
            alert(err)
        }
    }

    return (
        <div>
            <div style={{display: 'flex', gridGap: '35%', marginTop: '3%'}}>
                <div>
                    {user
                        ?
                            <div>
                                <h1>Данные пользователя</h1>
                                <h4>Имя: {user[0]}</h4>
                                <h4>Реферальный код: {user[1]}</h4>
                                <h4>Баланс: {ball} PROFI</h4>
                                {user[2]
                                    ?
                                        <h4>Реферальный код друга: {user[2]}</h4>
                                    :
                                        <></>
                                }
                                {user[3]
                                    ?
                                        <h4>Процент скидки: {user[3].toString()}</h4>
                                    :
                                        <></>
                                }
                                {user[4]
                                    ?
                                        <h6>Реферальный код активирован</h6>
                                    :
                                        <h6>Реферальный код не активирован</h6>
                                }


                                {user[0] == 'Owner'
                                    ?
                                        <div>
                                            <div>
                                            <Button onClick={() => setShow(true)}>создать nft</Button>

                                            <Modal show={show} onHide={() => setShow(false)}>
                                                <Modal.Body >
                                                    <Form className="mb-3" onSubmit={sNft} style={{display: 'flex', flexDirection: 'column', alignItems: 'center'}} >
                                                        <h1 style={{textAlign: 'center'}}>Введите информацию о nft</h1>
                                                        <Form.Group>
                                                            <Form.Control value={_nft.name} onChange={e => set_Nft({..._nft, name: e.target.value})} style={{width: '280px'}} type="text" placeholder="введите название" required/>
                                                            <Form.Control value={_nft.desc} onChange={e => set_Nft({..._nft, desc: e.target.value})} style={{width: '280px'}} type="text" placeholder="введите описание" required/>

                                                            <Form.Control value={_nft.price} onChange={e => set_Nft({..._nft, price: e.target.value})} type="number" min={1} title="введите стоимость" required/>
                                                            <Form.Control value={_nft.amount} onChange={e => set_Nft({..._nft, amount: e.target.value})} type="number" min={1} title="введите количество" required/>
                                                            <input type="file" required onChange={file}/>
                                                        </Form.Group>
                                                        <Button style={{marginLeft: '10px', marginTop: '3%' ,width: '150px'}} variant="primary" type="submit">создать</Button>
                                                    </Form> 
                                                </Modal.Body>
                                            </Modal>
                                            </div>
                                        </div>
                                    :
                                        <></>
                                }
                            </div>
                        :
                            <></>
                    }
                </div>

                <div>
                    {user
                        ?
                            <div>
                                {user[0] == 'Owner'
                                    ?
                                        <div>
                                            <Form className="mb-3" onSubmit={sCol} style={{display: 'flex', flexDirection: 'column', alignItems: 'center'}} >
                                                <h1>Создать коллекцию</h1>
                                                <Form.Group>
                                                    <Form.Control value={col.name} onChange={e => setCol({...col, name: e.target.value})} style={{width: '280px'}} type="text" placeholder="введите название" required/>
                                                    <Form.Control value={col.desc} onChange={e => setCol({...col, desc: e.target.value})} style={{width: '280px'}} type="text" placeholder="введите описание" required/>
                                                </Form.Group>
                                                <Button style={{marginLeft: '10px', marginTop: '3%' ,width: '150px'}} variant="primary" type="submit">отправить</Button>
                                            </Form> 

                                            {/* <div>
                                            <Button onClick={() => setShow(true)}>создать nft</Button>

                                            <Modal show={show} onHide={() => setShow(false)}>
                                                <Modal.Body >
                                                    <Form className="mb-3" onSubmit={sNft} style={{display: 'flex', flexDirection: 'column', alignItems: 'center'}} >
                                                        <h1 style={{textAlign: 'center'}}>Введите информацию о nft</h1>
                                                        <Form.Group>
                                                            <Form.Control value={_nft.name} onChange={e => set_Nft({..._nft, name: e.target.value})} style={{width: '280px'}} type="text" placeholder="введите название" required/>
                                                            <Form.Control value={_nft.desc} onChange={e => set_Nft({..._nft, desc: e.target.value})} style={{width: '280px'}} type="text" placeholder="введите описание" required/>

                                                            <Form.Control value={_nft.price} onChange={e => set_Nft({..._nft, price: e.target.value})} type="number" min={1} title="введите стоимость" required/>
                                                            <Form.Control value={_nft.amount} onChange={e => set_Nft({..._nft, amount: e.target.value})} type="number" min={1} title="введите количество" required/>
                                                            <input type="file" required onChange={file}/>
                                                        </Form.Group>
                                                        <Button style={{marginLeft: '10px', marginTop: '3%' ,width: '150px'}} variant="primary" type="submit">создать</Button>
                                                    </Form> 
                                                </Modal.Body>
                                            </Modal>
                                            </div> */}
                                        </div>
                                    :
                                        <></>
                                }
                            </div>
                        :
                            <></>
                    }
                </div>

            </div>




            <div style={{display: 'flex', gridGap: '40%', marginTop: '7%'}}> 
                <div>
                    <h1 style={{textAlign: 'center'}}>Ваши nft</h1>
                    {nft.length
                        ?
                            <></>
                        :
                            <h5>Пока тут пусто</h5>
                    }
                    {nft.map(n => 
                        <Nft nft={n} lk={true} signer={signer} contract={contract} key={n[1][1]}></Nft>
                    )}
                </div>

                <div>
                    <h1 style={{textAlign: 'center'}}>Ваши коллекции</h1>
                    {collection.length
                        ?
                            <></>
                        :
                            <h5>Пока тут пусто</h5>
                    }
                    {collection.map(c => 
                        <Collection col={c} lk={true} signer={signer} contract={contract} key={c[0]}></Collection>
                    )}
                </div>
            </div>
            
        </div>
    )
}