package idv.cjcat.stardustextended.flashdisplay.handlers
{

import idv.cjcat.stardustextended.emitters.Emitter;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.particles.Particle;
import idv.cjcat.stardustextended.xml.XMLBuilder;

/**
 * This handler adds display object particles to the target container's display list,
 * removes dead particles from the display list,
 * and updates the display object's x, y, rotation, scaleX, scaleY, and alpha properties.
 */
public class DisplayObjectHandler extends ParticleHandler
{

    public var addChildMode : int;
    /**
     * The target container.
     */
    public var container : DisplayObjectContainer;
    /**
     * Whether to change a display object's parent to the target container if the object already belongs to another parent.
     */
    public var forceParentChange : Boolean;
    /**
     * The blend mode for drawing.
     */
    private var _blendMode : String;

    private var displayObj : DisplayObject;

    public function DisplayObjectHandler(container : DisplayObjectContainer = null, blendMode : String = "normal", addChildMode : int = 0)
    {
        this.container = container;
        this.addChildMode = addChildMode;
        this.blendMode = blendMode;
        forceParentChange = false;
    }

    override public function particleAdded(particle : Particle) : void
    {
        displayObj = DisplayObject(particle.target);
        displayObj.blendMode = _blendMode;

        if (!forceParentChange && displayObj.parent) return;

        switch (addChildMode) {
            case AddChildMode.RANDOM:
                container.addChildAt(displayObj, Math.floor(Math.random() * container.numChildren));
                break;
            case AddChildMode.TOP:
                container.addChild(displayObj);
                break;
            case AddChildMode.BOTTOM:
                container.addChildAt(displayObj, 0);
                break;
            default:
                container.addChildAt(displayObj, Math.floor(Math.random() * container.numChildren));
                break;
        }
    }

    override public function particleRemoved(particle : Particle) : void
    {
        displayObj = DisplayObject(particle.target);
        displayObj.parent.removeChild(displayObj);
    }

    override public function stepEnd(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {
        for each (var particle : Particle in particles) {
            displayObj = DisplayObject(particle.target);

            displayObj.x = particle.x;
            displayObj.y = particle.y;
            displayObj.rotation = particle.rotation;
            displayObj.scaleX = displayObj.scaleY = particle.scale;
            displayObj.alpha = particle.alpha;
        }
    }

    public function set blendMode(val : String) : void
    {
        _blendMode = val;
    }

    public function get blendMode() : String
    {
        return _blendMode;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName() : String
    {
        return "DisplayObjectHandler";
    }

    override public function toXML() : XML
    {
        var xml : XML = super.toXML();

        xml.@addChildMode = addChildMode;
        xml.@forceParentChange = forceParentChange;
        xml.@blendMode = _blendMode;

        return xml;
    }

    override public function parseXML(xml : XML, builder : XMLBuilder = null) : void
    {
        super.parseXML(xml, builder);

        if (xml.@addChildMode.length()) addChildMode = parseInt(xml.@addChildMode);
        if (xml.@forceParentChange.length()) forceParentChange = (xml.@forceParentChange == "true");
        if (xml.@blendMode.length()) blendMode = (xml.@blendMode);
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}