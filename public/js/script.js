/*
function persistInput(input) {
    let key = "input-" + input.id;

    let storedValue = localStorage.getItem(key);

    if (storedValue) {
        input.value = storedValue;
    }

    input.addEventListener('input', () => {
        localStorage.setItem(key, input.value);
    });
}

let responsibleInput = document.querySelector("input#responsible");
if (responsibleInput) {
    persistInput(responsibleInput);
}
*/
$(window).on("load resize ", function() {
    let scrollWidth = $('.tbl-content').width() - $('.tbl-content table').width();
    $('.tbl-header').css({'padding-right':scrollWidth});
}).resize();

/* VUE */
Vue.component(`responsible-input`, {
    props: {
        responsible_person: {
            type: String
        },
        label_text: {
            default: "Responsible person",
            type: String
        },
        name: {
            type: String
        }
    },
    data() {
        return {
            text: ""
        }
    },
    template: '#responsibleTemplate',
    methods: {
        handleChange() {                    
            this.$emit(`update-responsible`, this.text);
        }
    },
    created() {
        this.text = this.responsible_person;
    }
});

Vue.component(`copiable-input`, {
    props: {
        content: {
            type: String
        }
    },
    data() {
        return {
            text: ""
        }
    },
    template: '#copiableTemplate',
    methods: {
        onClick() {
            this.$refs.textarea.select();
            try {
                let successful = document.execCommand('copy');
                if (successful) {
                    this.$emit(`alert-notify`, "Copied to clipboard");
                } else {
                    this.$emit(`alert-error`, "Failed to copy to clipboard");
                }
            } catch (err) {
                this.$emit(`alert-error`, "Failed to copy to clipboard");
            }
        }
    },
    created() {
        this.text = this.content;
    }
});

function validate(binding) {
    if (typeof binding.value !== 'function') {
      console.warn('[Vue-click-outside:] provided expression', binding.expression, 'is not a function.')
      return false
    }
  
    return true
  }
  
function isPopup(popupItem, elements) {
    if (!popupItem || !elements)
        return false

    for (var i = 0, len = elements.length; i < len; i++) {
        try {
            if (popupItem.contains(elements[i])) {
                return true
            }
            if (elements[i].contains(popupItem)) {
                return false
            }
        } catch(e) {
            return false
        }
    }

    return false
}

Vue.directive('click-outside', {
    bind: function(el, binding, vNode) {
        if (!validate(binding)) return

        // Define Handler and cache it on the element
        function handler(e) {
            if (!vNode.context) return

            // some components may have related popup item, on which we shall prevent the click outside event handler.
            var elements = e.path || (e.composedPath && e.composedPath())
            elements && elements.length > 0 && elements.unshift(e.target)            
        
            if (el.contains(e.target) || isPopup(vNode.context.popupItem, elements)) return

            el.__vueClickOutside__.callback(e)
        }

        // add Event Listeners
        el.__vueClickOutside__ = {
            handler: handler,
            callback: binding.value
        }
        document.addEventListener('click', handler)
    },
    update: function (el, binding) {
        if (validate(binding)) el.__vueClickOutside__.callback = binding.value
    },
    unbind: function(el, binding) {
        // Remove Event Listeners
        document.removeEventListener('click', el.__vueClickOutside__.handler)
        delete el.__vueClickOutside__

    }
});

Vue.component(`loanable-component`, {
    props: {
        id: {
            type: String
        },
        loanable_name: {
            type: String
        },
        loanable_type: {
            type: String
        },
        keyword: {
            type: String,
            default: ""
        },
        is_card: {
            type: Boolean
        }
    },
    data() {
        return {
            is_shown: false,
            deleted: false,
            is_card_shown: false
        }
    },
    methods: {
        showDropdown() {
            this.$eventHub.$emit(`hide-all-dropdowns`);
            this.is_shown = !this.is_shown;        
        },
        hideDropdown() {
            this.is_shown = false;      
        },
        showCard() {
            this.is_card_shown = true;
        },
        hideCard() {
            this.is_card_shown = false;
        },
        deleteLoanable() {
            this.$http.get(`/loans/${this.loanable_type}/${this.id}/delete`)
            .then(response => response.json())
            .then(json => {
                if (json["successful"] === "true") {
                    this.onDeleted();
                } else {
                    let error = json["error"] ? json["error"] : `${this.loanable_name} could not be deleted.`;
                    this.failedDeleted(error);
                }
            }, response => {
                this.failedDeleted(`${this.loanable_name} could not be deleted.`);
            });            
        },
        onDeleted() {
            this.$emit(`alert-notify`, `${this.loanable_name} was successfully deleted.`);
            this.deleted = true;
        },
        failedDeleted(error) {
            this.$emit(`alert-error`, error);
        }
    },
    created() {
        this.$eventHub.$on('hide-all-dropdowns', this.hideDropdown);
    },    
    beforeDestroy() {
        this.$eventHub.$off('hide-all-dropdowns');
    },
    render: function(h) {
        let html_tag = this.is_card ? "div" : "tr";
        return h(html_tag, this.$scopedSlots.default({loanable_scope: {
            deleted: this.deleted,
            is_shown: this.is_shown,
            is_card_shown: this.is_card_shown,
            showDropdown: this.showDropdown,
            hideDropdown: this.hideDropdown,
            showCard: this.showCard,
            hideCard: this.hideCard,
            deleteLoanable: this.deleteLoanable
        }}));
    }
});

/*
Vue.component(`loanable-card`, {
    props: {
        show_context: {
            type: Boolean
        }, 
        id: {
            type: String
        },
        loanable_type: {
            type: String
        },
        url: {
            type: String
        },
        card_name: {
            type: String
        },
        subtitle1: {
            type: String
        },
        subtitle2: {
            type: String
        },
        hidden_label: {
            type: String
        },
        hidden_content: {
            type: String
        },
        keyword: {
            type: String,
            default: ""
        }
    },
    data() {
        return {
            is_shown: false,
            deleted: false,
            update_url: ""
        }
    },
    template: '#loanableCard',
    methods: {
        showDropdown() {
            this.$eventHub.$emit(`hide-all-dropdowns`);
            this.is_shown = !this.is_shown;        
        },
        hideDropdown() {
            this.is_shown = false;            
        },
        deleteLoanable() {
            this.$http.post(`/loans/${this.loanable_type}/${this.id}/delete`)
            .then(response => response.json())
            .then(json => {
                if (json["successful"] === "true") {
                    this.onDeleted();
                } else {
                    let error = json["error"] ? json["error"] : `${this.card_name} could not be deleted.`;
                    this.failedDeleted(error);
                }
            }, response => {
                this.failedDeleted(`${this.card_name} could not be deleted.`);
            });            
        },
        onDeleted() {
            this.$emit(`alert-notify`, `${this.card_name} was successfully deleted.`);
            this.deleted = true;
        },
        failedDeleted(error) {
            this.$emit(`alert-error`, error);
        }
    },
    created() {
        this.$eventHub.$on('hide-all-dropdowns', this.hideDropdown);
        this.update_url = `/loans/${this.loanable_type}/${this.id}/edit`
    },
    beforeDestroy() {
        this.$eventHub.$off('hide-all-dropdowns');
    }
});
*/

Vue.component(`loaned-component`, {
    props: {
        keyword: {
            type: String,
            default: ""
        }
    },
    data() {
        return {
            is_card_shown: false
        }
    },
    methods: {
        showCard() {
            this.is_card_shown = true;
        },
        hideCard() {
            this.is_card_shown = false;
        }
    },
    render: function(h) {
        let html_tag = this.is_card ? "div" : "tr";
        return h(html_tag, this.$scopedSlots.default({loanable_scope: {
            is_card_shown: this.is_card_shown,
            showCard: this.showCard,
            hideCard: this.hideCard
        }}));
    }
});

Vue.component(`loaned-lightbox`, {
    props: {
        id: {
            type: String
        },
        card_name: {
            type: String
        },
        subtitle1: {
            type: String
        },
        subtitle2: {
            type: String
        },
        loaned_by: {
            type: String
        },
        purpose: {
            type: String
        },
        location: {
            type: String
        },
        loaned_at: {
            type: String
        },
        loaned_count: {
            type: String
        }
    },
    template: '#lightbox'
});

Vue.component(`alert-notify`, {
    props: {
        alert: {
            default: "",
            type: String
        }
    },
    data() {
        return {
            text: "",
            is_active: false
        }
    },
    template: '#alertNotify',/*
    methods: {
        doAlert(alert) {
            console.log("test");
            this.is_active = true;
            this.text = alert;
        }
},*/
    created() {
        if (this.alert != "") {
            this.is_active = true;
            this.text = this.alert;
        }
    }
});

Vue.component(`alert-error`, {
    props: {
        alert: {
            default: "",
            type: String
        }
    },
    data() {
        return {
            text: "",
            is_active: false
        }
    },
    template: '#alertError',/*
    methods: {
        doAlert(alert) {
            console.log("test error");
            this.is_active = true;
            this.text = alert;
        }
    },*/
    created() {
        if (this.alert != "") {
            this.is_active = true;
            this.text = this.alert;
        }
    }
});

Vue.component(`search`, {
    data() {
        return {
            keyword: ""
        }
    },
    template: '#searchTemplate',
    methods: {
        onChange() {
            this.$emit(`on-search`, this.keyword.toLowerCase());
        }
    }
});

Vue.prototype.$eventHub = new Vue(); // Global event bus

let app = new Vue({
    el: `#app`,
    data: {
        responsible: "",
        errorAlert: "",
        notifyAlert: "",
        keyword: ""
    },
    methods: {
        updateResponsible(responsible) {
            localStorage.setItem("responsible", responsible);
        },
        doAlertError(alert) {
            this.errorAlert = alert;
        },
        doAlertNotify(alert) {
            this.notifyAlert = alert;
        },
        onSearch(keyword) {
            this.keyword = keyword;
        }
    },
    created() {
        let responsible = localStorage.getItem("responsible");
        if (responsible !== null) {
            this.responsible = responsible;
        }
    }
});