RoomsData = []
currentRoom = null
roomOpen = false
searchOpen = false
pinnedOpen = false

QB.Phone.Functions.LoadChatRooms = (ChatRooms) => {
    $("#joined-rooms-list").html("");
    $("#public-rooms-list").html("");
    $("#pinned-rooms-list").html("");
    let PlayerCID = QB.Phone.Data.PlayerData.citizenid
    let joined = []
    let public = []
    let pinned = []

    $.each(ChatRooms, (i, room) => {
        if(PlayerCID == room.room_owner_id && ! room.is_pinned) {
            joined.push(room)
        }
        
        if(Number(room.protected) == 0 && ! room.is_pinned) {
            public.push(room)
        }

        if(room.is_pinned) {
            pinned.push(room)
        }

        if(room.room_members !== '{}') {
            let members = JSON.parse(room.room_members)
            $.each(members, (i, member) => {
                if(member.cid == PlayerCID && ! room.is_pinned) {
                    joined.push(room)
                }
            })
        }
    })

    RoomsData = ChatRooms

    RenderJoinedChatRooms(joined)
    RenderPublicChatRooms(public)
    RenderPinnedChatRooms(pinned)
}

function htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, "text/html");
    
    return doc.documentElement.textContent;
}

$(document).on('click', '.chat-image', function(e){
    e.preventDefault();
    let source = $(this).find('img').attr('src')
    QB.Screen.popUp(source)
});

QB.Phone.Functions.RefreshGroupChat = (messageData) => {
    if(currentRoom && currentRoom === messageData.room_id) {
        let chatTime = $.timeago(new Date())
        let split = messageData.message.split(" ")

        $.each(split, (k, v) => {
            v = htmlDecode(v)

            if(v.match(/(https?:\/\/.*\.(?:png|jpg|jpeg))/i)) {
                split[k] = `<div class="chat-image"><img src="${v}" alt="Picture" /></div>`
            }
        })

        split = split.join(" ")

        if(messageData.messageType == "SYSTEM") {
            $('.chat-view').prepend(`
                <div class="group-chat-message system-message">
                    <div class="group-message">
                        <div class="group-chat-message-info">
                            <div class="group-chat-message-from"><i class="fas fa-exclamation-circle"></i> ${messageData.name}</div>
                            <div class="group-chat-message-time">${chatTime}</div>
                        </div>
                        <div class="group-chat-message-contents">
                            ${messageData.message}
                        </div>
                    </div>
                </div>
            `)
        } else { 
            $('.chat-view').prepend(`
                <div class="group-chat-message">
                    <div class="group-message">
                        <div class="group-chat-message-info">
                            <div class="group-chat-message-from">${messageData.memberName}</div>
                            <div class="group-chat-message-time">${chatTime}</div>
                        </div>
                        <div class="group-chat-message-contents">
                            <a href="#" class="pin-message" data-roomid="${messageData.room_id}" data-pinned="false" data-messageid="${messageData.messageID}"><i class="fa fa-thumbtack"></i></a>

                            ${split}
                        </div>
                    </div>
                </div>
            `)
        }

        $('.chat-view').animate({scrollTop: $('.chat-view').prop("scrollHeight")}, 500)
    }
}

RenderJoinedChatRooms = (JoinedChatRooms) => {
    let container = $("#joined-rooms-list")

    if( ! $.isEmptyObject(JoinedChatRooms)) {
        $('#joined-rooms-container').show()

        $.each(JoinedChatRooms, function (i, Room) {
            let element = `
                <div class="group-chat-listing" data-roomID="${Room.id}">
                    <div class="chat-name">
                        <span><i class="fa fa-hashtag"></i></span> ${Room.room_name} (${Room.room_code})
                    </div>

                    <div class="chat-meta">
                        <div class="chat-owner"><i class="fas fa-crown"></i> <span>${Room.room_owner_name}</span></div>
                    </div>
                </div>
            `;

            container.append(element)
        })
    } else {
        $('#joined-rooms-container').hide()
        $('#public-rooms-list').css('height', '31vh')
    }
}

RenderPinnedChatRooms = (PinnedChatRooms) => {
    let container = $("#pinned-rooms-list")
    if( ! $.isEmptyObject(PinnedChatRooms)) {
        $.each(PinnedChatRooms, function (i, Room) {
            switch(Room.room_name) {
                case "Events":
                    icon = '<i class="far fa-calendar-alt"></i>'
                break
                case "411":
                    icon = '<i class="fas fa-hands-helping"></i>'
                break
                case "The Lounge":
                    icon = '<i class="fas fa-couch"></i>'
                break
            }

            let element = `
                <div class="pinned-chat-listing" data-roomID="${Room.id}">
                    <div class="pinned-chat-name">
                        ${Room.room_name}
                    </div>

                    <div class="pinned-chat-icon">
                        ${icon}
                    </div>
                </div>
            `;

            container.append(element)
        })
    }
}

RenderPublicChatRooms = (PublicChatRooms) => {
    let container = $("#public-rooms-list")

    if( ! $.isEmptyObject(PublicChatRooms)) {
        $("#no-public-rooms-notice").hide()
        container.show()

        $.each(PublicChatRooms, function (i, Room) {
            let element = `
                <div class="group-chat-listing" data-roomid="${Room.id}">
                    <div class="chat-name">
                        <span><i class="fa fa-hashtag"></i></span> ${Room.room_name}
                    </div>

                    <div class="chat-meta">
                        <div class="chat-owner"><i class="fas fa-crown"></i> <span>${Room.room_owner_name}</span></div>
                    </div>
                </div>
            `;

            container.append(element)
        });
    } else {
        $("#no-public-rooms-notice").show()
        container.hide()
    }
}

RenderMemberList = (id) => {
    var members = {};
    var owner = {name, id};
    var container = $('#members-list').html("");

    $.each(RoomsData, (i, room) => {
        if(room.id == id) {
            // The room exists
            if(room.room_members) members = JSON.parse(room.room_members);
            
            owner.name = room.room_owner_name;
            owner.id = room.room_owner_id;
        }
    })

    if( ! $.isEmptyObject(members)) {
        container.append(`
            <div class="chat-member">
                <img src="https://via.placeholder.com/150" alt="">
                <p><i class="fa fa-star"></i>  ${owner.name}</p>
            </div>
        `);
        $.each(members, function(member, memberData) {
            if(QB.Phone.Data.PlayerData.citizenid === owner.id) {
                container.append(`
                    <div class="chat-member">
                        <img src="https://via.placeholder.com/150" alt="">
                        <p>${memberData.name}</p>
                        <div class="chat-member-manage">
                            <i class="fa fa-user-minus" id="remove-member" data-roomid="${id}" data-cid="${member}"></i>
                        </div>
                    </div>
                `);
            } else {
                container.append(`
                    <div class="chat-member">
                        <img src="https://via.placeholder.com/150" alt="">
                        <p>${memberData.name}</p>
                    </div>
                `);
            }

        })
    } else {
        container.append(`
            <div class="chat-member">
                <img src="https://via.placeholder.com/150" alt="">
                <p><i class="fa fa-star"></i>  ${owner.name}</p>
            </div>
        `);        
    }
}
RenderChatMessages = (messages) => {
    let container = $(".chat-view")
    container.html("")

    if( ! messages) {
        container.html(`
            <div class="group-chat-message system-message">
                <div class="group-chat-message-info">
                    <div class="group-chat-message-from">SYSTEM</div>
                    <div class="group-chat-message-time"></div>
                </div>

                <div class="group-chat-message-contents">
                    There are currently no messages in this chat room.
                </div>
            </div>
        `)
    } else {
        $.each(messages, (i, chat) => {
            let chatTime = $.timeago(new Date(chat.created))
            let split = chat.message.split(" ")

            $.each(split, (k, v) => {
                v = htmlDecode(v)
    
                if(v.match(/(https?:\/\/.*\.(?:png|jpg|jpeg))/i)) {
                    split[k] = `<div loading="lazy" class="chat-image"><img src="${v}" alt="Picture" /></div>`
                }
            })
    
            split = split.join(" ")
            
            if(chat.member_id == "SYSTEM") {
                container.append(`
                    <div class="group-chat-message system-message">
                        <div class="group-message">
                            <div class="group-chat-message-info">
                                <div class="group-chat-message-from"><i class="fas fa-exclamation-circle"></i> ${chat.member_name}</div>
                                <div class="group-chat-message-time">${chatTime}</div>
                            </div>
                            <div class="group-chat-message-contents">
                                ${split}
                            </div>
                        </div>
                    </div>
                `)
            } else {
                container.append(`
                <div class="group-chat-message">
                    <div class="group-message">
                        <div class="group-chat-message-info">
                            <div class="group-chat-message-from">${chat.member_name}</div>
                            <div class="group-chat-message-time">${chatTime}</div>
                        </div>
                        <div class="group-chat-message-contents" ${chat.is_pinned ? 'style="border-style:dashed;border-color:#FFFF33;background:rgb(44, 70, 95)"' : ''}>
                            <a href="#" class="pin-message" data-pinned="${chat.is_pinned}" data-roomid="${chat.room_id}" data-messageid="${chat.id}"><i class="fa fa-thumbtack"></i></a>
                            ${split}
                        </div>
                    </div>
                </div>
            `)
                
            }
        })
    }
}

/**
 * Check if a user is the owner of a room
 * 
 * @param {int} roomId 
 */
let isUserAnOwner = (roomId) => {
    let isOwner = false

    $.each(RoomsData, (i, room) => {
        if(room.id == roomId) {
            if(QB.Phone.Data.PlayerData.citizenid === room.room_owner_id) {
                isOwner = true

                return false
            }
        }
    })

    return isOwner
}

/**
 * Check if a user belongs to a particular room ID
 * 
 * @param {int} roomId 
 * 
 * @returns boolean
 */
let isUserAMember = (roomId) => {
    let members = {},
        isMember = false
    

    $.each(RoomsData, (i, room) => {
        if(room.id == roomId) {
            // The room exists
            if(room.room_members) members = JSON.parse(room.room_members)
            
            if( ! $.isEmptyObject(members)) {
                $.each(members, function(member, memberData) {      
                    if(QB.Phone.Data.PlayerData.citizenid === memberData.cid || QB.Phone.Data.PlayerData.citizenid === room.room_owner_id) {
                        isMember = true

                        return false
                    }
                })
            } else {
                if(QB.Phone.Data.PlayerData.citizenid === room.room_owner_id) {
                    isMember = true

                    return false
                }
            }
        }
    })

    return isMember
}

function getChatRoomData() {
    let chat = {}

    $.each(RoomsData, (k, room) => {
        if(room.id === currentRoom) {
            chat = room
        }
    })

    return chat
}

$('#leave-room').on('click', e => {
    e.preventDefault()

    let cid = QB.Phone.Data.PlayerData.citizenid

    $.post("https://qb-phone/LeaveGroupChat", JSON.stringify({roomID: currentRoom, citizenid: cid}), function(status) {
        if(status) {
            $('.chat-room-leave').hide()
            $('.chat-room-join').show()
            $('#members-back-btn').trigger('click')
            $("#submit-message").prop('disabled', true)
            $("#submit-message").prop('placeholder', 'Be a member to chat!')
            QB.Phone.Notifications.Add("fa fa-check", "Discord", "You have left #" + slug(getChatRoomData().room_name), "#1DA1F2", 2500)
        }  
    })
})


$('#join-room').on('click', e => {
    e.preventDefault()
    $.post("https://qb-phone/JoinGroupChat", JSON.stringify({roomID: currentRoom}), function(status) {
        if(status) {
            $('.chat-room-join').hide()
            $('.chat-room-leave').show()
            $('#members-back-btn').trigger('click')
            $("#submit-message").prop('disabled', false)
            $("#submit-message").prop('placeholder', 'Press [ENTER] to chat!')

            QB.Phone.Notifications.Add("fa fa-check", "Discord", "You are now a member of #" + slug(getChatRoomData().room_name), "#1DA1F2", 2500)
        }
    })
})

$(".chat-room-back").on('click', e => {
    $(".chat-room-view").hide("slide", { direction: "left" }, 200)

    if(roomOpen) {
        $('.search-results').slideUp(200, () => {
            $('#search-messages-content').html("")
            $('#search-message').val("")
        }) 

        $('.pinned-results').slideUp(200, () => {
            $('#pinned-messages-content').html("")
        }) 
        
        roomOpen = false
    }  
    currentRoom = null
    searchOpen = false
    pinnedOpen = false
})  

$('#search-messages').on('click', e => {
    if(pinnedOpen) {
        $('#pinned-messages').trigger('click')
    }

    if( ! searchOpen) {
        $('.search-results').slideDown({
            start: function () {
                $(this).css({
                    display: "flex"
                })
                }
        }, () => {
            $('#search-messages-content').html("")
        })  
        searchOpen = true
    } else {
        searchOpen = false
        $('.search-results').slideUp(200, () => {
            $('#search-messages-content').html("")
            $('#search-message').val("")
        })           
    }
})

$('#search-message').keypress(e => {
    if(e.which == 13) {
        let keyword = $('#search-message').val()
        let previousSearch = ""

        if(keyword !== previousSearch && keyword !== "" && keyword.length >= 3) {
            $("#search-messages-content").html("")

            $.post("https://qb-phone/SearchGroupChatMessages", JSON.stringify({roomID: currentRoom, searchTerm: keyword}), function(messages) {
                if( ! messages) {
                    $("#no-search-notice").show()
                    $("#search-messages-content").html("")
                } else {
                    previousSearch = keyword

                    $("#no-search-notice").hide()

                    $.each(messages, (k, chat) => {
                        let chatTime = $.timeago(new Date(chat.created))
                        let split = chat.message.split(" ")

                        $.each(split, (k, v) => {
                            v = htmlDecode(v)
                
                            if(v.match(/(https?:\/\/.*\.(?:png|jpg|jpeg))/i)) {
                                split[k] = `<div loading="lazy" class="chat-image"><img src="${v}" alt="Picture" /></div>`
                            }
                        })
                
                        split = split.join(" ")
                        $("#search-messages-content").append(`
                            <div class="group-chat-message">
                                <div class="group-message">
                                    <div class="group-chat-message-info">
                                        <div class="group-chat-message-from">${chat.member_name}</div>
                                        <div class="group-chat-message-time">${chatTime}</div>
                                    </div>
                                    <div class="group-chat-message-contents">
                                        ${split}
                                    </div>
                                </div>
                            </div>
                        `)
                    })
                }
            })
        } 
    } 
})

$('#pinned-messages').on('click', e => {
    if(searchOpen) {
        $('#search-messages').trigger('click')
    }

    if( ! pinnedOpen) {
        $('#no-pinned-notice').hide()

        $('.pinned-results').slideDown({
            start: function () {
                $(this).css({
                    display: "flex"
                })
                }
        }, () => {
            $('#pinned-messages-content').html("")
        })  
        pinnedOpen = true

        $.post("https://qb-phone/GetPinnedMessages", JSON.stringify({roomID: currentRoom}), function(results) {
            if( ! results) {
                $('#no-pinned-notice').show()
            } else {
                $('#no-pinned-notice').hide()

                $.each(results, (k, chat) => {
                    let chatTime = $.timeago(new Date(chat.created))
                    let split = chat.message.split(" ")

                    $.each(split, (k, v) => {
                        v = htmlDecode(v)
            
                        if(v.match(/(https?:\/\/.*\.(?:png|jpg|jpeg))/i)) {
                            split[k] = `<div loading="lazy" class="chat-image"><img src="${v}" alt="Picture" /></div>`
                        }
                    })
            
                    split = split.join(" ")
                    $("#pinned-messages-content").append(`
                        <div class="group-chat-message">
                            <div class="group-message">
                                <div class="group-chat-message-info">
                                    <div class="group-chat-message-from">${chat.member_name}</div>
                                    <div class="group-chat-message-time">${chatTime}</div>
                                </div>
                                <div class="group-chat-message-contents" ${chat.is_pinned ? 'style="border-style:dashed;border-color:#FFFF33;background:rgb(44, 70, 95)"' : ''}>
                                    <a href="#" class="pin-message" data-pinned="${chat.is_pinned}" data-roomid="${chat.room_id}" data-messageid="${chat.id}"><i class="fa fa-thumbtack"></i></a>

                                    ${split}
                                </div>
                            </div>
                        </div>
                    `)
                })              
            }
        })

    } else {
        pinnedOpen = false
        $('.pinned-results').slideUp(200, () => {
            $('#pinned-messages-content').html("")
        })           
    }
})


$("#close-search").on('click', e => {
    $('#search-messages-content').html("")
    $('#search-message').val("")       
    $('#no-search-notice').hide()      
})

$("#close-pinned").on('click', e => {
    $('#pinned-messages').html("")
    $('#no-pinned-notice').hide()      
})

/**
 * Renders the chat room page with messages.
 * 
 * @param {int} id 
 * @posts GetGroupChatMessages
 */
function openChatRoom(id) {
    currentRoom = id
    let data = getChatRoomData()

    roomOpen = true

    $(".chat-room-view").show("slide", { direction: "left" }, 200)
    $(".chat-room-title span").text(slug(data.room_name))

    if(isUserAMember(currentRoom) && ! isUserAnOwner(currentRoom)) {
        $('.chat-room-join').hide()
        $('.chat-room-leave').show()
    } else if( ! isUserAnOwner(currentRoom)) {
        $('.chat-room-join').show()      
        $('.chat-room-leave').hide()
    } else {
        $('.chat-room-leave').hide()
        $('.chat-room-join').hide()
    }

    $.post("https://qb-phone/GetGroupChatMessages", JSON.stringify({roomID: currentRoom}), function(messages) {
        RenderChatMessages(messages)  
    }) 
    $("#submit-message").prop('placeholder', 'Press [ENTER] to chat!')

    if( ! isUserAMember(id) && ! isUserAnOwner(id)) {
        $("#submit-message").prop('disabled', true)
        $("#submit-message").prop('placeholder', 'Be a member to chat!')
    } else {
        $("#submit-message").prop('disabled', false)
    }
}

/**
 * Converts a string to slug case.
 * 
 * @param {string} str 
 * @returns 
 */
function slug( str ) {
    str = str.replace(/[`~!@#$%^&*()_\-+=\[\]{};:'"\\|\/,.<>?\s]/g, ' ').toLowerCase();
    str = str.replace(/^\s+|\s+$/gm,'');
    str = str.replace(/\s+/g, '-');   

    return str;
}

var entityMap = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': '&quot;',
    "'": '&#39;',
    "/": '&#x2F;'
};

function _escape(string) {
    return String(string).replace(/[&<>"'\/]/g, function (s) {
        return entityMap[s];
    });
}

$("#submit-message").on('keypress', (e) => {
    let messageContent = _escape($("#submit-message").val())
    let timeout = false

    if(e.which === 13 && messageContent.length > 0) {
        if(timeout) return;

        timeout = true
        setTimeout(() => {
            timeout = false
        },3000)

        let messageData = {
            roomID: currentRoom,
            message: messageContent
        }

        $.post("https://qb-phone/SendGroupChatMessage", JSON.stringify(messageData), function() {
            $("#submit-message").val("")
        })
    }
})

$("#send-message").on('click', () => {
    let messageContent = _escape($("#submit-message").val())
    let timeout = false

    if(messageContent.length > 0) {
        if(timeout) return;

        timeout = true
        setTimeout(() => {
            timeout = false
        },3000)

        let messageData = {
            roomID: currentRoom,
            message: messageContent
        }

        $.post("https://qb-phone/SendGroupChatMessage", JSON.stringify(messageData), function(status) {
            $("#submit-message").val("")
        })
    }
})

$(document).on('click', '.chat-room-memberslist', e => {
    $(".chat-members-view").css({"display":"block"}).animate({
        left: 8+"vh"
    }, 250);

    $(".chat-room-view").animate({
        left: "-20vh"
    }, 250);
    
    RenderMemberList(currentRoom)  
})

$("#members-back-btn").on('click', function(e) {
    $(".chat-members-view").css({"display":"block"}).animate({
        left: 30+"vh"
    }, 250);
    $(".chat-room-view").animate({
        left: "0vh"
    }, 250);
}) 

/**
 * This listener handles rendering of the chat room pages
 */
$(document).on('click', '.group-chat-listing', function(e){
    let id = $(this).data("roomid");

    openChatRoom(id)
})

/**
 * This listener handles rendering of the chat room pages
 */
 $(document).on('click', '.pinned-chat-listing', function(e){
    let id = $(this).data("roomid");

    openChatRoom(id)
})

/**
 * This handler opens the modal window for viewing rooms that are owned
 * by the player.
 */
$(document).on('click', '#open-owned-rooms', function(e) {
    let container = $("#owned-room-items").html("")

    $("#owned-rooms-list").fadeIn(100, () => {
        $(".modal-overlay").show()
    })

    $("#owned-rooms-list-close").on('click', function(e) {
        e.preventDefault();

        $("#owned-rooms-list").fadeOut(100);
        $(".modal-overlay").fadeOut(100);
    })
    
    if( ! $.isEmptyObject(RoomsData)) {
        let noRooms = true

        $.each(RoomsData, (i, room) => {
            if(QB.Phone.Data.PlayerData.citizenid === room.room_owner_id) {
                let bal = room.unpaid_balance ? room.unpaid_balance.toLocaleString('en-US', {style: 'currency', currency: 'USD'}) : '$0'
                let membersCount = Object.keys(JSON.parse(room.room_members)).length

                container.append(`
                    <div class="room-list-item" data-roomid="${room.id}">
                        <div class="room-list-name"><span><i class="fa fa-hashtag"></i></span>${slug(room.room_name)}</div>
                        <div class="room-info">
                            <div class="room-code"><i class="fa fa-handshake"></i>${room.room_code}</div>
                            <div class="room-pin">${Number(room.protected) == 1 ? '<i class="fas fa-lock"></i> Private' : '<i class="fa fa-globe"></i> Public'}</div>
                        </div>

                        <div class="room-settings">
                            <div class="room-balance">
                                <div class="setting-icon"><i class="fa fa-users"></i></div>
                                <div class="setting-data">${membersCount ? membersCount : 0}</div>
                            </div>

                            <div class="room-set-pin">
                                <div class="setting-icon"><i class="fas fa-lock"></i></div>
                                <div class="settings-data">
                                    <input type="password" id="change-pin" data-roomId="${room.id}" maxlength="50" type="password">
                                </div>
                            </div>

                            <div class="room-deactivate">
                                <div class="setting-icon"><i class="fas fa-power-off"></i></div>
                                <div class="settings-data">
                                    <a href="#" class="deactivate-room" data-roomid="${room.id}">Deactivate</a>
                                </div>
                            </div>
                        </div>
                    </div>
                `)
                noRooms = false 
            }
        })

        if(noRooms) {
            $('#no-owned-rooms-notice').show()
        }
    } else {
        $('#no-owned-rooms-notice').show()
    }
})

$(document).on('click', '.deactivate-room', function(e) {
    let room = $(this).data('roomid')

    $('.confirm').attr('data-roomid', room)

    $("#confirm-deactivation").fadeIn(100)

    $("#confirm-deactivation-close").on('click', function(e) {
        e.preventDefault();

        $("#confirm-deactivation").fadeOut(100);
    })
})

$(document).on('click', '.confirm', function(e) {
    let room = parseInt($(this).attr('data-roomid'))
    if( ! isUserAnOwner(room)) {
        QB.Phone.Notifications.Add("fa fa-times", "Not Owner", "You don't have permission for that.", "#1DA1F2", 4000);   
    } else {
        $.post("https://qb-phone/DeactivateRoom", JSON.stringify({roomID: room}), function(status) {
            if(status) {
                $('#owned-rooms-list-close').trigger('click')
                $('#confirm-deactivation-close').trigger('click')

                QB.Phone.Notifications.Add("fa fa-check", "Discord", "You have deactivated the room.", "#1DA1F2", 2500)

            } else {
                QB.Phone.Notifications.Add("fa fa-times", "Discord", "Failed to deactivate the room.", "#1DA1F2", 2500)
            }
        })       
    }  
})

$('.reject').on('click', function(e) {
    $('#confirm-deactivation-close').trigger('click')
})


$(document).on('keypress', '#change-pin', function(e) {
    if(e.which == 13) {
        let pin = $(this).val()
        let id  = $(this).data('roomid')
        let pinOk = false

        $.each(RoomsData, (k, v) => {
            if(v.id == id) {
                if(pin.length <= 50) {
                    pinOk = true
                }

                return false
            }
        })

        if(pinOk) {
            $.post("https://qb-phone/ChangeRoomPin", JSON.stringify({pinCode: pin, roomID: id}), function(status) {
                if(status) {
                    $('#change-pin').val(pin)
                    $('#owned-rooms-list-close').trigger('click')
                    QB.Phone.Notifications.Add("fa fa-check", "Discord", "Room passcode successfully changed!", "#1DA1F2", 2500)
                } else {
                    QB.Phone.Notifications.Add("fa fa-times", "Discord", "Failed to change room passcode.", "#1DA1F2", 2500)
                }
            })
        } else {
            QB.Phone.Notifications.Add("fa fa-times", "Discord", "Your new passcode was not accepted, must be less than 50 characters.", "#1DA1F2", 2000)
        }
    }
})

/**
 * This handler expands the owned rooms list in the modal window
 * revealing information about the owners room.
 */
$(document).on('click', '.room-list-name', function(e){
    e.preventDefault();
   
    if( ! $(this).parent().hasClass('room-list-item-show')) {
        $(this).parent().addClass('room-list-item-show')
    }
    else {
        $(this).parent().removeClass('room-list-item-show')
    }
})

/**
 * Opens the input room code modal window for joining rooms by code
 */
$(document).on('click', '#open-private-rooms', function(e) {
    $("#options-room-code").fadeIn(100, () => {
        $(".modal-overlay").show()
    })

    $("#options-room-code-close").on('click', function(e) {
        e.preventDefault();

        $("#options-room-code").fadeOut(100);
        $(".modal-overlay").fadeOut(100);
    })
})

function closeCreateChannel(){
    $("#create-room-code").fadeOut(100);
    $(".modal-overlay").fadeOut(100);
}

$(document).on('click', '#disc-create-channel', function(e) {
    $("#options-room-code").fadeOut(100);
    $("#create-room-code").fadeIn(100, () => {
        $(".modal-overlay").show()
    })

    $("#create-room-cancel").on('click', function(e) {
        closeCreateChannel()
    })
})

$("#create-room-cancel").on('click', function(e) {
    e.preventDefault();
    closeCreateChannel()
})

$("#create-room-confirm").on('click', function(e) {
    let channelName = $('.create-room-name').val()
    let channelPass = $('.create-room-passcode').val()
    $.post("https://qb-phone/CreateDiscordRoom", JSON.stringify({name: channelName, pass: channelPass}), function(status) {
        if(status) {
            QB.Phone.Notifications.Add("fab fa-discord", "Discord", "You have sucsesfully purchased a room!", "#1DA1F2", 2500)
        } else {
            QB.Phone.Notifications.Add("fab fa-discord", "Discord", "You can\'t afford a room!", "#1DA1F2", 2500)
        }
        e.preventDefault();
        closeCreateChannel()
    })
})
$("#disc-join-channel").on("click", function(e) {
    $("#options-room-code").fadeOut(100);
    $("#join-room-code").fadeIn(100, () => {
        $(".modal-overlay").show()
    })
    
    $("#join-room-code-close").on('click', function(e) {
        e.preventDefault();
        $("#join-room-code").fadeOut(100);
        $(".modal-overlay").fadeOut(100);
    
    })
})

$('.room-input-code').keypress((e) => {
    if(e.which == 13) {
        let chatroom
        let code = $('.room-input-code').val()

        $.each(RoomsData, (k, v) => {
            if(v.room_code === code) {
                chatroom = v  
            }
        })

        if(chatroom) {
            if(chatroom.room_owner_id === QB.Phone.Data.PlayerData.citizenid) {
                $("#join-room-code-close").trigger('click')

                QB.Phone.Notifications.Add("fa fa-times", "Discord", "You are already the owner of this room.", "#1DA1F2", 4000)
                openChatRoom(chatroom.id)
                $('.room-input-code').val("")
                
            } else if(isUserAMember(chatroom.id)) {
                $("#join-room-code-close").trigger('click')

                QB.Phone.Notifications.Add("fa fa-times", "Discord", "You are already a member of this room.", "#1DA1F2", 4000)
                openChatRoom(chatroom.id)
                $('.room-input-code').val("")

            } else if(Number(chatroom.protected) == 1) {
                $("#join-room-code").hide()

                $("#room-pin-input").attr('data-roomID', chatroom.id)
                $('#enter-room-pin h4').html("Enter Passcode: <br><br> #" + slug(chatroom.room_name))
                $("#enter-room-pin").fadeIn(100, () => {
                    $(".modal-overlay").show()
                })
            } else {
                let id = chatroom.id
                $("#join-room-code-close").trigger('click')
                $.post('https://qb-phone/JoinGroupChat', JSON.stringify({roomID: id}), () => {
                    openChatRoom(chatroom.id)
                    QB.Phone.Notifications.Add("fa fa-check", "Discord", "You are now a member of #" + slug(chatroom.room_name), "#1DA1F2", 4000)
                    
                    $('.chat-room-join').hide()
                    $('.chat-room-leave').show()
                    $("#submit-message").prop('disabled', false)
                    $("#submit-message").prop('placeholder', 'Press [ENTER] to chat!')
                })   
                $('.room-input-code').val("")
            }

        } else {
            QB.Phone.Notifications.Add("fa fa-times", "Room Not Found", "Room doesn't exist, try again.", "#1DA1F2", 4000)
            $('.room-input-code').val("")
        }
    }
})

$("#enter-room-pin-close").on('click', function(e) {
    e.preventDefault();

    $("#enter-room-pin").fadeOut(100);
    $(".modal-overlay").fadeOut(100);
})

$('#room-pin-input').keypress(e => {
    if(e.which == 13) {
        let pin = $('#room-pin-input').val()
        let id  = $('#room-pin-input').data('roomid')
        
        currentRoom = id
        let chatroom = getChatRoomData()
        $.post('https://qb-phone/JoinGroupChat', JSON.stringify({roomID: id, roomPin: pin}), (status) => {
            if(status) {
                $("#enter-room-pin-close").trigger('click')

                QB.Phone.Notifications.Add("fa fa-check", "Discord", "You are now a member of #" + slug(chatroom.room_name), "#1DA1F2", 4000);   
                openChatRoom(id)
                $('.chat-room-join').hide()
                $('.chat-room-leave').show()
                $('#room-pin-input').val("")
                $("#submit-message").prop('disabled', false)
                $("#submit-message").prop('placeholder', 'Press [ENTER] to chat!')
            } else {
                QB.Phone.Notifications.Add("fa fa-times", "Discord", "That pin code is incorrect.", "#1DA1F2", 4000)
            }
        })  
    }
})

$(document).on('mouseover', '.group-chat-message', function(e) {
    if(isUserAnOwner(currentRoom))
        if( ! $(this).parents('.system-message').length) {
            $(this).find('.pin-message').fadeIn(100)
        }
})

$(document).on('mouseleave', '.group-chat-message', function(e) {
    if( ! $(this).parents('.system-message').length) {
        $(this).find('.pin-message').fadeOut(100)
    }
})

$(document).on('click', '.pin-message', function(e) {
    let room = $(this).attr('data-roomid')
    let message = $(this).attr('data-messageid')
    let $this = $(this)

    $.post("https://qb-phone/ToggleMessagePin", JSON.stringify({roomID: room, messageID: message}), function(status) {
        if( ! status) {
            QB.Phone.Notifications.Add("fa fa-times", "Discord", "You don't have permission to do that.", "#1DA1F2", 4000)
        } else {
            QB.Phone.Notifications.Add("fa fa-info", "Discord", "You have changed the pinned status.", "#1DA1F2", 4000)
            
            if($this.attr('data-pinned').length) {
                let value = ($this.attr('data-pinned') === 'true')

                if(value) {
                    $this.parents('.group-chat-message').remove()

                    if( ! $.trim($("#pinned-messages-content").html()).length) {
                        $("#no-pinned-notice").show()
                    }  
                }
            }
        }
    })
})

$(document).on('click', '#remove-member', function(e){
    e.preventDefault();
   
    let room = $(this).attr('data-roomid')
    let cid = $(this).attr('data-cid')

    $.post("https://qb-phone/LeaveGroupChat", JSON.stringify({roomID: room, citizenid: cid}), function(status) {
        if(status) {
            $(this).remove();


            $('#members-back-btn').trigger('click')
            QB.Phone.Notifications.Add("fa fa-check", "Discord", "You have removed a member.", "#1DA1F2", 2500)
        } 
    })
})