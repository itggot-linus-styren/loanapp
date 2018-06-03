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

Vue.component(`custom-select`, {
    props: {    
        select_selected: {
            type: String,
            default: ""
        }
    },
    data() {
        return {
            select_hide: true,
            select_content: this.select_selected
        }
    },
    methods: {        
        showSelect() {
            this.$eventHub.$emit(`hide-all-dropdowns`);
            this.select_hide = false;
        },
        hideSelect() {
            this.select_hide = true;
        },
        toggleSelect() {
            if (this.select_hide) {
                this.showSelect();
            } else {
                this.hideSelect();
            }
        },
        select(new_value) {
            this.select_content = new_value;
        }
    },
    created() {
        this.$eventHub.$on('hide-all-dropdowns', this.hideSelect);
    },
    beforeDestroy() {
        this.$eventHub.$off('hide-all-dropdowns');
    },
    render: function(h) {
        return h("div", this.$scopedSlots.default({select_scope: this}));
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
        brand: {
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
            this.$eventHub.$emit(`hide-all-dropdowns`);
            this.is_card_shown = true;
        },
        hideCard() {
            this.is_card_shown = false;
        },
        hideAllDropdowns() {
            this.is_shown = false;
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
        },
        matchSearch() {
            return this.loanable_name.toLowerCase().includes(this.keyword.toLowerCase()) ||
                   this.brand.toLowerCase().includes(this.keyword.toLowerCase());
        }
    },
    created() {
        this.$eventHub.$on('hide-all-dropdowns', this.hideAllDropdowns);
    },    
    beforeDestroy() {
        this.$eventHub.$off('hide-all-dropdowns');
    },
    render: function(h) {
        let html_tag = this.is_card ? "div" : "tr";
        return h(html_tag, this.$scopedSlots.default({loanable_scope: this}));
    }
});

Vue.component(`loaned-component`, {
    props: {
        loanable_name: {
            type: String
        },
        loaned_by: {
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
            is_card_shown: false
        }
    },
    methods: {
        showCard() {
            this.is_card_shown = true;
        },
        hideCard() {
            this.is_card_shown = false;
        },
        matchSearch() {
            return this.loanable_name.toLowerCase().includes(this.keyword.toLowerCase()) ||
                   this.loaned_by.toLowerCase().includes(this.keyword.toLowerCase());
        }
    },
    render: function(h) {
        let html_tag = this.is_card ? "div" : "tr";
        return h(html_tag, this.$scopedSlots.default({loanable_scope: this}));
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
    template: '#alertNotify',
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
    template: '#alertError',
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
        },
        onChange() {
            this.$emit(`on-search`, this.keyword.toLowerCase());
        }
    },
    created() {
        let responsible = localStorage.getItem("responsible");
        if (responsible !== null) {
            this.responsible = responsible;
        }
    }
});

$('input[type="checkbox"]').on('change', function() {
    $('input[type="checkbox"]').not(this).prop('checked', false);
 });