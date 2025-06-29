import React, { useEffect, useState } from "react";
import { Button } from 'react-bootstrap'
import { useNavigate } from 'react-router-dom';


export default function Collection(props) {

    const router = useNavigate()

    const toId = () => {
        router(`/lk/${props.col[0]}`)
    }
    
    return (
        <div>
            <h5>id коллекции: {props.col[0].toString()}</h5>
            <p>Название: {props.col[1]}</p>
            <p>Описание: {props.col[2]}</p>
            {props.col[3].length
                ?
                    <p>id nft в коллекции: {props.col[3].toString()}</p>
                :
                    <p>Пока тут пусто, давайте добавим nft!</p>
            }
            {props.lk
                ?
                    <Button onClick={toId}>добавить nft/создать аукцион</Button>
                :
                <></>
            }
            
        </div>
    )
}