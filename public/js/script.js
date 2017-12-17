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
    directives: {
      'click-outside': {
        bind: function(el, binding, vNode) {
          // Provided expression must evaluate to a function.
          if (typeof binding.value !== 'function') {
              const compName = vNode.context.name
            let warn = `[Vue-click-outside:] provided expression '${binding.expression}' is not a function, but has to be`
            if (compName) { warn += `Found in component '${compName}'` }
            
            console.warn(warn);
          }
          // Define Handler and cache it on the element
          const bubble = binding.modifiers.bubble;
          const handler = (e) => {
            if (bubble || (!el.contains(e.target) && el !== e.target)) {
                binding.value(e);
            }
          }
          el.__vueClickOutside__ = handler;
  
          // add Event Listeners
          document.addEventListener('click', handler);
              },
        
        unbind: function(el, binding) {
          // Remove Event Listeners
          document.removeEventListener('click', el.__vueClickOutside__);
          el.__vueClickOutside__ = null;
  
        }
      }
    },
    methods: {
        toggleCard() {
            /*let radio = $(this.$refs.radio);
            if ($('input[name=card]:checked').is(radio)) {
                if (radio.prop('checked')) {
                    radio.prop('checked', false);
                } else {
                    radio.prop('checked', true);
                }
            }*/
        },
        showDropdown() {
            this.is_shown = !this.is_shown;        
        },
        hideDropdown() {
            this.is_shown = false;            
        },
        deleteLoanable() {
            this.$http.get(`/delete/${this.loanable_type}/${this.id}`)
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
        this.update_url = `/update/${this.loanable_type}/${this.id}`
    }
});

Vue.component(`loaned-card`, {
    props: {
        id: {
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
        loaned_by: {
            type: String
        },
        keyword: {
            type: String,
            default: ""
        }
    },
    data() {
        return {
            popupurl: ""
        }
    },
    template: '#loanedCard',
    methods: {
        toggleCard() {
            /*let radio = $(this.$refs.radio);
            if ($('input[name=card]:checked').is(radio)) {
                if (radio.prop('checked')) {
                    radio.prop('checked', false);
                } else {
                    radio.prop('checked', true);
                }
            }*/
        }
    },
    created() {
        this.popupurl = "#" + this.id
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