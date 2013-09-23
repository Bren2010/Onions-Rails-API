window.onload = ->
    document.getElementById('user-form')?.onsubmit = ->
        # Store the raw password in client storage, and hash the values that are
        # going to be sent.
        user = document.getElementById 'user'
        pass = document.getElementById 'pass'
        amplify.store 'password', pass.value
        
        user.value = sjcl.codec.base64.fromBits sjcl.hash.sha256.hash user.value
        pass.value = sjcl.codec.base64.fromBits sjcl.hash.sha256.hash pass.value
        
        true
    
    document.getElementById('create-onion')?.onsubmit = ->
        # Encrypt the new onion.
        pass = amplify.store 'password'
        title = document.getElementById 'new-title'
        info = document.getElementById 'new-info'
        
        title.value = sjcl.encrypt pass, title.value
        info.value = sjcl.encrypt pass, info.value
        
        true
    
    
    pass = amplify.store 'password'
    editOnions = $('[id^="edit-onion-"]')
    
    for form in editOnions
        form.onsubmit = ->
            # Encrypt the edited onion.
            pass = amplify.store 'password'
            title = document.getElementById 'edit-title-' + this.Id.value
            info = document.getElementById 'edit-info-' + this.Id.value
            
            title.value = sjcl.encrypt pass, title.value
            info.value = sjcl.encrypt pass, info.value
            
            true
        
        title = document.getElementById 'edit-title-' + form.Id.value
        info = document.getElementById 'edit-info-' + form.Id.value
        
        try
            title.value = sjcl.decrypt pass, title.value
            info.value = sjcl.decrypt pass, info.value
        catch
            title.value = 'Onion has been tampered with!'
            info.value = 'Will not decrypt.'
