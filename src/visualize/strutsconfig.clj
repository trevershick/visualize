(ns visualize.strutsconfig
  (:require [clojure.xml :as xml] )
  (:require [clojure.string :as string] )
  (:gen-class))

(comment (def xml (xml/parse "struts-config.xml")))

(defn strip-suffix [url] (.replaceAll url ".do.*" ""))  ; strip .do off the end fo the string
(defn strip-slashes [url] (string/replace url "/" "_"))
(defn strip-periods [url] (string/replace url "." "_"))
(defn normalize-action-path [path] (strip-periods (strip-suffix (strip-slashes path))))
(defn action-id [path] (str "a_" (normalize-action-path path)))
(defn is-action [path] (.contains path ".do"))

(defmulti fillcolor-for-node identity)
(defmethod fillcolor-for-node "action" [stereotype] (str "red"))
(defmethod fillcolor-for-node "forward" [stereotype] (str "blue"))
(defmethod fillcolor-for-node :default [stereotype] (str "grey"))


(defn box [id stereotype label]
	(let [fillcolor (fillcolor-for-node stereotype)]
		(string/join [ 
				id 
				" [label=\"<" stereotype ">\\n" label "\""
				",shape=" "box"
				",fillcolor=" fillcolor 
				",style=filled"
				",fontcolor=white"
				"];" ]
		)
	)
)


(defn forward-path-label [path]
		(cond
			(.contains path "main.jsp?content=") (second (re-find #"content=([^&]+)" path))
			(.contains path "main.jsp?c=") (second (re-find #"c=([^&]+)" path))
			:default (str path)
		)
)
(defn forward-path-id [path] 
	(cond
		(.contains path "main.jsp?content=") (normalize-action-path (second (re-find #"content=([^&]+)" path)))
		(.contains path "main.jsp?c=") (normalize-action-path (second (re-find #"c=([^&]+)" path)))
		(is-action path) (action-id path) 
		:default (normalize-action-path path)
	)
)

(defn get-child-elements [xmlseq element-name]  (filter #(= element-name (:tag %)) xmlseq))  
(defn get-child-element [xmlseq element-name]  (first (filter #(= element-name (:tag %)) xmlseq)))  




(defn globalforward [forward-element]  ;  gf is an xml element that has :tag, :content, and :attrs 
	( let [
		rawpath (:path (:attrs forward-element))
		rawname (:name (:attrs forward-element))
		path rawpath
		label (str rawname "\\n" rawpath)
		stereotype "global forward" 
		id (str "gf_" rawname)] 
		(seq [	
			(str "global_forwards -> " id ";")
			(box id stereotype label)
			])
	)
)

(defn forward [forward-element parent-action]  ;  gf is an xml element that has :tag, :content, and :attrs 
	( let [
		rawpath (:path (:attrs forward-element))
		rawname (:name (:attrs forward-element))
		path rawpath
		node-label (str (forward-path-label rawpath))
		edge-label rawname
		stereotype "forward" 
		id (forward-path-id rawpath)] 
		(seq [	
			(if (not(is-action path)) (box id stereotype node-label))
			(str parent-action " -> " id "[label=\"" edge-label "\"labeldistance=0];")
			])
		
	)
)


(defn action [act]  ;  act is an xml element that has :tag, :content, and :attrs 
	( let [
		rawpath (:path (:attrs act))
		path (normalize-action-path rawpath)
		name rawpath  
		id (action-id rawpath)
		forwards (get-child-elements (:content act) :forward)
		defaultforward (:forward (:attrs act))
		forwardparam (:parameter (:attrs act))
		] 
		(seq [	
		 	(comment (str "action_mappings -> " id ";"))
			(box id "action" name) 
			(map #(forward % id) forwards)
			(if (not(nil? defaultforward)) (forward {
				:attrs {:path defaultforward, :name "default"}
				} id) )
			(if (not(nil? forwardparam)) (forward {
				:attrs {:path forwardparam, :name "always"}
				} id) )
			])
	)
)



(defn get-action-mappings [xmlseq] (get-child-element xmlseq :action-mappings))
(defn get-global-forwards [xmlseq] (get-child-element xmlseq :global-forwards))

(defn action-mappings [struts-config-element]  ;; struts-config is an xml element with :content, :attrs, etc..
	(let 
		[action-elements (:content (get-action-mappings (:content struts-config-element))) ] 
		( map action action-elements)
	)
)
	
(defn global-forwards [struts-config-element]
	(let 
		[ forward-elements (:content (get-global-forwards (:content struts-config-element))) ]
		( map globalforward forward-elements)
	)
)


(defn transform[struts-config] 
	(let [	gf (global-forwards struts-config)
			am (action-mappings struts-config)]
		(string/join "\n" (flatten [
			"digraph {"
			"rankdir=LR"
			"edge [fontname=Verdana,fontsize=12]"
			"node [shape=\"box\",fontsize=12,fontname=Verdana]"
			"label=\"Struts Config\";"
			(global-forwards struts-config)
			(action-mappings struts-config)  ; have to get the 'content' from struts-config
			"}"])	
		)))
		
(defn -main [& args] (
	println (transform (xml/parse (first args))))
)
