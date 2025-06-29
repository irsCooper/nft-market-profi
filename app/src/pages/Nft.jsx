import React, { useState } from "react";
import { Button, Form } from 'react-bootstrap'

export default function Nft(props) {

    const [price, setPrice] = useState(0)
    const [friend, setFriend] = useState('')

    const sell = async (e) => {
        e.preventDefault()

        try {
            const c = props.contract
            const s = props.signer
    
            const res = await c.connect(s).sellNft(Number(props.nft[1][0]), price)
            console.log(price, Number(props.nft[1][0]), res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
        } catch(err) {
            alert(err)
        }
    }

    const forFriend = async (e) => {
        e.preventDefault()

        try {
            const c = props.contract
            const s = props.signer
    
            const res = await c.connect(s).transferNftForFriend(Number(props.nft[1][0]), friend)
            console.log(friend, Number(props.nft[1][0]), res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
        } catch(err) {
            alert(err)
            console.log(err)
        }
    }

    const buy = async (e) => {
        e.preventDefault()

        try {
            const c = props.contract
            const s = props.signer
    
            const res = await c.connect(s).buyNft(Number(props.nft[0]))
            console.log(Number(props.nft[0]), res)
            alert('Подождите ответа блокчейна, результат скоро отобразится')
        } catch(err) {
            alert(err)
            console.log(err)
        }
    }

    // onSell()
    // console.log(props.nft)
    return (
        <div style={{border: '5px solid black', width: '459px', margin: '10px'}}>
            <img width='450px' src={'./images/' + props.nft[1][3]}></img>
            <h4>Название: {props.nft[1][1]}</h4>
            <p>Описание: {props.nft[1][2]}</p>
            {props.nft[3]
                ?
                    <p>Принадлежит коллекции: {props.nft[3]}</p>
                :
                    <></>
            }

            {props.nft[4]
                ?
                    <p>Описание коллекции: {props.nft[4]}</p>
                :
                    <></>
            }

            {props.nft[1][4]
                ?
                    <p>Стоимость: {props.nft[1][4].toString()}</p>
                :
                    <></>
            }
            <p>Количество: {props.nft[1][5].toString()}</p>
            <p>Дата создания: {props.nft[1][6].toString()}</p>
            <p>id: {props.nft[1][0].toString()}</p>
            {props.lk
                ?
                    <div>
                        {props.nft[5]
                            ?
                                <p>Продаётся</p>
                            :
                                <div>
                                    <Form style={{display: 'flex'}} className="mb-3" onSubmit={forFriend}>
                                        <Form.Group>
                                            <Form.Control value={friend} onChange={e => setFriend(e.target.value)} style={{width: '280px'}} type="text" placeholder="введите адрес друга" required/>
                                        </Form.Group>
                                        <Button style={{marginLeft: '10px'}} variant="primary" type="submit">отправить</Button>
                                    </Form> 

                                    <Form style={{display: 'flex'}} className="mb-3" onSubmit={sell}>
                                        <Form.Group>
                                            <Form.Control value={price} onChange={e => setPrice(Number(e.target.value))} style={{width: '280px'}} type="number" min={1} title="введите стоимость"/>
                                        </Form.Group>
                                        <Button style={{marginLeft: '10px', width: '104px'}} variant="primary" type="submit">продать</Button>
                                    </Form> 
                                </div>
                        }
                    </div>
                :
                    
                    <div>
                        <p>Владелец: {props.nft[2]}</p>
                        <Form style={{display: 'flex'}} className="mb-3" onSubmit={buy}>
                            <Button style={{marginLeft: '10px', width: '104px'}} variant="primary" type="submit">купить</Button>
                        </Form> 
                    </div>
            }

        </div>
    )
}